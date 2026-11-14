"""Mux the existing AAC score and verify this caption-only rerender.

Run from any directory with Python 3; no third-party Python modules required.
The old scored film is an explicit input because the site's current film changes.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

HERE = Path(__file__).resolve().parent
PROOF = HERE.parent.parent
WORKSPACE = PROOF.parent.parent.parent
OLD_SCORED_SHA = 'a841b5fd34c414d861b10f85ea354463a8ec60893e300c9edb44c6d901e67dc9'
OLD_SILENT_SHA = 'da85feb2f1bd89dee9d5a78b0faba04b8ba6e8649d807820d7c372b0958e8eb9'
OLD_RENDERER_SHA = '6dd9753b0e8589d6f923fed45b157a402c0b64b2ff9b424c7333933ef7ee905b'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(*args):
    return subprocess.run([str(a) for a in args], check=True, capture_output=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--original-scored', type=Path, required=True)
    parser.add_argument('--original-panels', type=Path, default=WORKSPACE / 'build/crazy-box-explainer')
    parser.add_argument('--output', type=Path, default=WORKSPACE / 'build/ink-crawl-caption-fix')
    parser.add_argument('--ffmpeg', type=Path)
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    old = args.original_scored.resolve()
    out = args.output.resolve()
    ff = args.ffmpeg or next((Path.home() / 'AppData/Local/Overwolf/Extensions').rglob('ffmpeg.exe'))
    probe = ff.with_name('ffprobe.exe')
    assert sha(old) == OLD_SCORED_SHA, 'Supply the archived, pre-caption-fix scored film.'
    silent_original = PROOF / 'docs/media/ink-films/original-crawl-silent.mp4'
    archived_renderer = PROOF / 'instrumentation/ink-film-soundtrack/source-crawl/render.ps1'
    assert sha(silent_original) == OLD_SILENT_SHA
    assert sha(archived_renderer) == OLD_RENDERER_SHA
    silent = out / 'crawl-caption-corrected.mp4'
    scored = out / 'crawl-with-music.mp4'
    assert old != scored
    if not args.check_only:
        run(ff, '-hide_banner', '-loglevel', 'error', '-y', '-i', silent, '-i', old,
            '-map', '0:v:0', '-map', '1:a:0', '-c:v', 'copy', '-c:a', 'copy',
            '-movflags', '+faststart', scored)

    def metadata(path):
        return json.loads(run(probe, '-v', 'error', '-show_streams', '-show_format', '-of', 'json', path).stdout)

    def elementary(path, kind):
        fmt, codec = ('adts', '-c:a') if kind == 'a' else ('h264', '-c:v')
        data = run(ff, '-hide_banner', '-loglevel', 'error', '-i', path,
                   '-map', '0:' + kind + ':0', codec, 'copy', '-f', fmt, '-').stdout
        return hashlib.sha256(data).hexdigest()

    metadata_all = {}
    for key, path in [('oldScored', old), ('correctedSilent', silent), ('correctedScored', scored)]:
        data = metadata(path)
        video = next(s for s in data['streams'] if s['codec_type'] == 'video')
        assert (video['width'], video['height'], video['r_frame_rate'], int(video['nb_frames'])) == (1600, 900, '30/1', 3742)
        assert abs(float(video['duration']) - 124.733333) < 0.000001
        run(ff, '-hide_banner', '-v', 'error', '-xerror', '-i', path, '-f', 'null', '-')
        metadata_all[key] = {'sha256': sha(path), 'bytes': path.stat().st_size,
                             'durationSeconds': float(video['duration']), 'frameCount': int(video['nb_frames']),
                             'width': video['width'], 'height': video['height'], 'fps': video['r_frame_rate'],
                             'videoCodec': video['codec_name'], 'fullDecodePassed': True}
    audio_before = elementary(old, 'a')
    audio_after = elementary(scored, 'a')
    assert audio_before == audio_after
    old_video = elementary(old, 'v')
    new_silent_video = elementary(silent, 'v')
    new_scored_video = elementary(scored, 'v')
    assert new_silent_video == new_scored_video and old_video != new_scored_video
    old_audio = next(s for s in metadata(old)['streams'] if s['codec_type'] == 'audio')
    new_audio = next(s for s in metadata(scored)['streams'] if s['codec_type'] == 'audio')
    for key in ('codec_name', 'sample_rate', 'channels', 'time_base', 'start_pts', 'start_time', 'duration_ts', 'duration', 'nb_frames'):
        assert old_audio[key] == new_audio[key], (key, old_audio[key], new_audio[key])
    def packet_timing(path):
        return json.loads(run(probe, '-v', 'error', '-select_streams', 'a:0', '-show_packets',
                              '-show_entries', 'packet=pts,dts,duration,flags,side_data_list', '-of', 'json', path).stdout)
    old_packets = packet_timing(old)
    new_packets = packet_timing(scored)
    assert old_packets == new_packets, 'AAC packet timing or skip/discard metadata changed.'
    packet_timing_sha = hashlib.sha256(json.dumps(old_packets, sort_keys=True, separators=(',', ':')).encode()).hexdigest()

    source_receipt_path = PROOF / 'docs/media/ink-handsfree-native/supplied-handoff-receipt.json'
    source_receipt = json.loads(source_receipt_path.read_text(encoding='utf-8-sig'))
    expected_shas = {s['file']: s['sha256'] for s in source_receipt['screenshots']}
    selection = json.loads((out / 'selection.json').read_text(encoding='utf-8-sig'))
    expected_indices = [5, 5] + [6] * 5 + [7] * 2 + list(range(8, 28)) + [28] + list(range(29, 64)) + [63]
    expected_durations = [11, 11, 10, 10, 11, 10, 10, 11, 11] + [0.2] * 20 + [10] + [0.133333] * 35 + [11]
    assert [s['source'] for s in selection] == [f'super_mario_64-{i:03}.png' for i in expected_indices]
    assert [s['duration'] for s in selection] == expected_durations
    shots = PROOF / 'build/jp-ink-handoff-demo-20261112-a/shots'
    for record in selection:
        record['sourceSha256'] = sha(shots / record['source'])
        assert record['sourceSha256'] == expected_shas[record['source']]
    assert (args.original_panels / 'frames.txt').read_bytes() == (out / 'frames.txt').read_bytes()
    shell = shutil.which('pwsh') or shutil.which('powershell')
    crops = json.loads(run(shell, '-NoProfile', '-File', HERE / 'check-gameplay-panels.ps1',
                           '-OriginalPanels', args.original_panels, '-CorrectedPanels', out).stdout.decode('utf-8-sig'))
    assert len(crops) == len(selection) == 66
    labels = json.loads((out / 'label-measurements.json').read_text(encoding='utf-8-sig'))
    assert all(label['canvasFits'] for label in labels)
    corrected_labels = [label for label in labels if any(word in label['text'] for word in ('Stored', 'stored', 'graphics', 'drawn'))]
    assert all(label['right'] < 1538 and label['bottom'] < 900 for label in corrected_labels)
    renderer_text = (HERE / 'render.ps1').read_text(encoding='utf-8-sig')
    for bad in ('Where Mario is drawn', 'The game draws high', 'hidden by the solid top', 'high display Y'):
        assert bad not in renderer_text
    shutil.copyfile(HERE / 'storyboard.md', out / 'storyboard.md')
    receipt = {
        'schema': 1, 'date': '2026-11-13',
        'scope': 'Presentation-only caption correction. D means stored graphics coordinates; Y1741 does not establish where the model is drawn. No game run or Coq proof rerun.',
        'evidenceLevel': 'Same supplied-state original-JP handoff, not a continuous controller-reachable route.',
        'sourceRevision': run('git', '-C', PROOF, 'rev-parse', 'HEAD').stdout.decode().strip(),
        'originalScoredSource': old.relative_to(PROOF).as_posix() if old.is_relative_to(PROOF) else str(old),
        'correctedSilentFile': silent.name,
        'correctedScoredFile': scored.name,
        'correctedStoryboardFile': 'storyboard.md',
        'historicalRendererSha256': OLD_RENDERER_SHA,
        'historicalSilentSha256': OLD_SILENT_SHA,
        'correctedRendererSha256': sha(HERE / 'render.ps1'),
        'verifierSha256': sha(HERE / 'verify.py'),
        'pixelCheckerSha256': sha(HERE / 'check-gameplay-panels.ps1'),
        'storyboardSha256': sha(HERE / 'storyboard.md'),
        'sourceReceiptSha256': sha(source_receipt_path),
        'ffmpegVersion': run(ff, '-version').stdout.decode().splitlines()[0],
        'ffprobeVersion': run(probe, '-version').stdout.decode().splitlines()[0],
        'videos': metadata_all,
        'audio': {'policy': 'Existing AAC track stream-copied with -c:a copy. No recomposition or re-encoding.',
                  'adtsElementarySha256Before': audio_before, 'adtsElementarySha256After': audio_after,
                  'identical': True, 'codec': new_audio['codec_name'], 'sampleRate': new_audio['sample_rate'],
                  'channels': new_audio['channels'], 'startTimeSeconds': float(new_audio['start_time']),
                  'startPTS': int(new_audio['start_pts']), 'timeBase': new_audio['time_base'],
                  'durationTicks': int(new_audio['duration_ts']), 'durationSeconds': float(new_audio['duration']),
                  'packetTimingAndSkipMetadataIdentical': True, 'packetCount': len(old_packets['packets']),
                  'canonicalPacketTimingSha256': packet_timing_sha},
        'video': {'oldH264ElementarySha256': old_video, 'correctedH264ElementarySha256': new_scored_video,
                  'oldVideoStreamIdentical': False, 'correctedSilentAndScoredVideoIdentical': True,
                  'reason': 'Burned-in captions and diagram labels require rerendering; whole-video bytes are intentionally different.'},
        'poster': {'file': 'ink-gap.png', 'sha256': sha(out / 'ink-gap.png')},
        'verification': {'sourceCaptureBytesMatchArchivedReceipt': True, 'sourceSelectionAndCardDurationsUnchanged': True,
                         'concatManifestByteIdentical': True, 'all66GameplayPanelCropsPixelIdentical': True,
                         'uniqueTextMeasurements': len(labels), 'allTextFitsCanvas': True,
                         'allCorrectedTextFits1538PixelRightMargin': True,
                         'representativePanelReview': ['panel-005.png at 0:53', 'panel-006.png at 1:03'],
                         'visualReview': 'Correction panels inspected for readable captions and explicit stored-graphics/model distinction. No listening review or new gameplay claim.'},
        'changedLabelMeasurements': corrected_labels, 'sourceSelection': selection, 'gameplayPixelChecks': crops,
    }
    (out / 'caption-correction-receipt.json').write_bytes((json.dumps(receipt, ensure_ascii=False, indent=2) + '\n').encode('utf-8'))
    print(json.dumps({'receipt': str(out / 'caption-correction-receipt.json'),
                      'scoredSha256': sha(scored), 'silentSha256': sha(silent), 'aacSha256': audio_after,
                      'gameplayPanelsUnchanged': len(crops), 'textMeasurements': len(labels)}, indent=2))


if __name__ == '__main__':
    main()

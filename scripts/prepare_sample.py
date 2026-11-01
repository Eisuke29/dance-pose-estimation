"""公開デモと同じ8秒・12fpsの入力をPexelsから準備する。FFmpegが必要。"""
from pathlib import Path
import shutil
import subprocess

URL = 'https://videos.pexels.com/video-files/7571381/7571381-uhd_4096_2160_25fps.mp4'
PAGE = 'https://www.pexels.com/video/video-of-a-man-dancing-7571381/'

if __name__ == '__main__':
    root = Path(__file__).resolve().parents[1]
    output = root / 'src/input.mp4'
    if not shutil.which('ffmpeg'):
        raise SystemExit('FFmpegをインストールし、PATHへ追加してください。')
    if output.exists():
        raise SystemExit('src/input.mp4 は既にあります。元の入力を残すため上書きしません。')
    output.parent.mkdir(parents=True, exist_ok=True)
    print('素材: Antoni Shkraba / Pexels #7571381')
    print(PAGE)
    print('利用条件: https://www.pexels.com/license/')
    subprocess.run([
        'ffmpeg', '-hide_banner', '-loglevel', 'error', '-ss', '10', '-i', URL,
        '-t', '8', '-vf', 'scale=960:-2,fps=12', '-an', '-c:v', 'libx264',
        '-crf', '19', '-pix_fmt', 'yuv420p', str(output),
    ], check=True)
    print('src/input.mp4 を準備しました。素材単体の再配布は行わないでください。')

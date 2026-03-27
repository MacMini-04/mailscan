from flask import Flask, request, jsonify
import subprocess
import tempfile
import os

app = Flask(__name__)


@app.route('/ocr', methods=['GET', 'POST'])
def ocr():
    # GET is used by the Docker healthcheck
    if request.method == 'GET':
        return jsonify({'status': 'ok'})

    file = request.files.get('file')
    if not file:
        return jsonify({'error': 'No file provided'}), 400

    with tempfile.TemporaryDirectory() as tmpdir:
        pdf_path = os.path.join(tmpdir, 'mail.pdf')
        img_path = os.path.join(tmpdir, 'mail.jpg')
        txt_path = os.path.join(tmpdir, 'output')

        file.save(pdf_path)

        subprocess.run(
            ['magick', '-density', '150', f'{pdf_path}[0]', img_path],
            check=True
        )
        subprocess.run(
            ['tesseract', img_path, txt_path],
            check=True
        )

        with open(f'{txt_path}.txt', 'r') as f:
            text = f.read()

    return jsonify({'text': text})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)

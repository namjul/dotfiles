#!/usr/bin/env python

import tempfile
import genanki
from pathlib import Path
from flask import Flask, request, send_file
from markdown_anki_decks.cli import parse_markdown
from markdown_anki_decks.cli import ParseMarkdownResult  # Make sure this is imported if needed


app = Flask(__name__)

@app.route('/process', methods=['POST'])
def process():
    markdown_content = request.form.get('markdown')

    deck_title_prefix = "My Deck"
    generate_cloze_model = True


    with tempfile.NamedTemporaryFile(delete=False, suffix=".md") as temp_file, tempfile.TemporaryDirectory() as temp_dir:
        temp_file.write(markdown_content.encode('utf-8'))
        markdown_file_path = Path(temp_file.name)
        try:
            # Call the function
            deck, referenced_img_files, referenced_sound_files = parse_markdown(markdown_file_path, deck_title_prefix, generate_cloze_model)
            package = genanki.Package(deck)
            # package.media_files = referenced_img_files + referenced_sound_files
            path_to_pkg_file = Path(temp_dir, f"deck.apkg")
            package.write_to_file(path_to_pkg_file)

            # Use send_file to send the file as an HTTP response
            return send_file(path_to_pkg_file, as_attachment=True, download_name='deck.pgkg')
        finally:
            # Delete the file after sending it
            markdown_file_path.unlink()

app.run(host="unix:///tmp/app.sock")


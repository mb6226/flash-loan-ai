import os
import json
import tempfile
import shutil
from scripts.trigger_colab import ColabController


def test_sync_and_download(tmp_path, monkeypatch):
    # Use a temporary directory as DRIVE_FOLDER
    drive_dir = tmp_path / "drive"
    drive_dir.mkdir()

    monkeypatch.setenv('DRIVE_FOLDER', str(drive_dir))

    controller = ColabController()

    notebook_name = 'ai_data_collector.ipynb'
    params = {'test': True}

    # Run sync to save params
    controller.sync_with_drive(notebook_name, params)

    param_file = drive_dir / f"params_{notebook_name}.json"
    assert param_file.exists()

    loaded = json.loads(param_file.read_text(encoding='utf-8'))
    assert loaded['notebook'] == notebook_name
    assert loaded['params'] == params

    # Simulate results file
    results_file = drive_dir / f"results_{notebook_name}.json"
    results_data = {'status': 'done', 'value': 123}
    results_file.write_text(json.dumps(results_data), encoding='utf-8')

    downloaded = controller.download_results(notebook_name)
    assert downloaded == results_data

    # status file check
    status_file = drive_dir / f"status_{notebook_name}.json"
    status_file.write_text(json.dumps({'status': 'running'}), encoding='utf-8')
    status = controller.check_status(notebook_name)
    assert status == 'running'

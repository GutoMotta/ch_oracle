import os
import yaml

class FileList(object):
    def __init__(self, output_label, file_list=None):
        file_list_path = self._spath("src/file_list/file_list.yml")
        f = open(file_list_path)
        self.config = yaml.load(f)
        f.close()

        self.audio_files = self.create_list("audio")
        self.chroma_files = self.create_list("chroma", output_label)

        self.size = len(self.audio_files)

    def mkdir(self, dir_name):
        if not os.path.exists(dir_name):
            os.makedirs(dir_name)
        return dir_name

    def create_list(self, list_name, label=None):
        file_paths = self.config["files"]
        dirs = file_paths.keys()
        files = []
        for album_dir in dirs:
            dirname = self._dirname("%ss" % list_name, label, album_dir)
            dirpath = self.mkdir(self._spath(dirname))
            for basename in file_paths[album_dir]:
                files.append(self._filename(dirpath, basename, list_name))
        files.sort()

        return files

    def _spath(self, path):
        return os.path.abspath("%s/../../../%s" % (__file__, path))

    def _dirname(self, list_name, label, album):
        items = [list_name, label, album]
        return "/".join(item for item in items if item is not None)

    def _filename(self, dirpath, basename, extension_name):
        ext = self.config["%s_extension" % extension_name]
        return "%s/%s%s" % (dirpath, basename, ext)

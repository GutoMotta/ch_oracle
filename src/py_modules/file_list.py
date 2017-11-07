import os
import yaml

class FileList(object):
    def __init__(self, output_label, file_list=None):
        file_list_path = self._spath("src/file_list/file_list.yml")
        f = open(file_list_path)
        self.config = yaml.load(f)
        f.close()

        self.audio_files      = self.create_list("audio")
        self.chroma_files     = self.create_list("chroma", output_label)

        self.count = self.size = len(self.audio_files)

    def mkdir(self, dir_name):
        if not os.path.exists(dir_name):
            os.makedirs(dir_name)
        return dir_name

    def create_list(self, list_name, label=None):
        albuns = self.config["albuns"]
        files = []
        for album in albuns.keys():
            dirname = self._dirname("%ss" % list_name, label, album)
            dirpath = self.mkdir(self._spath(dirname))
            for basename in albuns[album]:
                files.append(self._filename(dirpath, basename, list_name))
        files.sort()

        return files

    def _spath(self, path):
        return os.path.abspath("%s/../../../%s" % (__file__, path))

    def _dirname(self, list_name, label, album):
        items = [list_name, label, album]
        return "/".join(item for item in items if item is not None)

    def _filename(self, dirpath, basename, extension_name):
        ext = self.config["extensions"][extension_name]
        return "%s/%s.%s" % (dirpath, basename, ext)

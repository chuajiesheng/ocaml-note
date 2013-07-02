#!/usr/bin/python -tt
import sys
from datetime import datetime
import time
import shlex, subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class ExitInterrupt(Exception):
    pass

class EventHandler(FileSystemEventHandler):
    def run_make(self):
        if (self._child != None):
            print "Terminate Existing Process."
            self._child.terminate()

        print "Starting Make Process"
        self._child = subprocess.Popen(self._args)

    def __init__(self):
        self._cmd = 'make test.byte'
        self._args = shlex.split(self._cmd)
        self._child = None
        self._previous = datetime.now()
        print "Init at", self._previous
        self.run_make()

    def on_modified(self, event):
        #print "On Modified"

        if (datetime.now() - self._previous).seconds > 5:
            self._previous = datetime.now()

            self.run_make()
        else:
            print "."

if __name__ == "__main__":
    if len(sys.argv) < 2:
        path = "."
    else:
        path = sys.argv[1]

    event_handler = EventHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print "Keyboard Interrupt Captured"
        observer.unschedule_all()
        observer.stop()
    observer.join()

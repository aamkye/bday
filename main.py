#!/usr/bin/env python

import asyncio
from hypercorn.config import Config
from hypercorn.asyncio import serve

from module import app

def main():
  asyncio.run(serve(app, Config()))

if __name__ == '__main__':
    main()

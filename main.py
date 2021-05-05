#!/usr/bin/env python

import os
import asyncio
import typing
import signal

from hypercorn.asyncio import serve
from hypercorn.config import Config

from fastapi import FastAPI

from module import router

shutdown_event = asyncio.Event()

app = FastAPI()
app.include_router(router.router)


def _signal_handler(*_: typing.Any) -> None:
    shutdown_event.set()


def main():
    config = Config()
    config.bind = "0.0.0.0:8080"
    config.use_reloader = bool(os.getenv("AUTO_RELOAD", False))

    loop = asyncio.get_event_loop()
    loop.add_signal_handler(signal.SIGTERM, _signal_handler)
    loop.run_until_complete(
        serve(
            app,
            config,
            shutdown_trigger=shutdown_event.wait
        )
    )


if __name__ == '__main__':
    main()

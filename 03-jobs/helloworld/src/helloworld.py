#!/usr/bin/env python3
import random
import time


def main():
    delay = random.randint(5, 15)
    print(f"sleeping for {delay} seconds", flush=True)
    time.sleep(delay)
    print("done", flush=True)
    

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass


import sys

def good(l):
    return len(l) > 4 and l[4].isdigit()

if __name__ == '__main__':
    is_code = False
    for l in sys.stdin.readlines():
        if ".area" in l:
            is_code = "(CODE)" in l
        elif is_code and good(l):
                sys.stdout.write(l[32:])


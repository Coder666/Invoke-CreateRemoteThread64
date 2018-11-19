import sys

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("bintohex.py <filename>")
        sys.exit(0)
        
    result ="{"

    with open(sys.argv[1], "rb") as f:
        bytes = f.read()

    
    for x in bytes:
        result = result + ("0x%.2X," % x)

        
    result += "};"

    print(result)
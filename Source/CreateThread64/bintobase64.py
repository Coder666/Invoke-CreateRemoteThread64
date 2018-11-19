import sys
import base64 
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("bintobase64.py <filename>")
        sys.exit(0)
        
    result ="{"

    with open(sys.argv[1], "rb") as f:
        bytes = f.read()

    
    result = base64.b64encode(bytes).decode("utf-8")

    print(result)
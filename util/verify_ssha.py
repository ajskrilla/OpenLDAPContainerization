#!/usr/bin/env python3
import sys, base64, hashlib

# 1) Replace these two with your actual values:
ssha_hash = "{SSHA}MtcWtA2DFYo8siFjKDAK9ryJAss="
password   = "jr4gupRPBhF1KIZV"

# 2) Strip the "{SSHA}" and Base64-decode
data = base64.b64decode(ssha_hash[6:])

# 3) Split into digest (first 20 bytes) and salt (the rest)
digest, salt = data[:20], data[20:]

# 4) Re-digest password+salt
if hashlib.sha1(password.encode() + salt).digest() == digest:
    print("✅ Hash VALID for that password")
    sys.exit(0)
else:
    print("❌ Hash DOES NOT match password")
    sys.exit(1)


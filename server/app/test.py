import os, json
import requests, jwt
import argparse
import traceback
import sys
from dotenv import load_dotenv

load_dotenv()


public_keys = {}
AAD_APP_CLIENT_ID = os.environ["AAD_APP_CLIENT_ID"]
AAD_APP_TENANT_ID = os.environ["AAD_APP_TENANT_ID"]
# ISSUER = os.environ["ISSUER"]
configReq = requests.get(
    f"https://login.microsoftonline.com/{AAD_APP_TENANT_ID}/.well-known/openid-configuration"
)
config = configReq.json()
# print(config)
ISSUER = config["issuer"]
# print(f"ISSUER: {ISSUER}")
jwks = requests.get(config["jwks_uri"]).json()
# print(jwks)
for jwk in jwks["keys"]:
    kid = jwk["kid"]
    public_keys[kid] = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(jwk))


def verify_jwt(token):
    import subprocess

    subprocess,
    # print(f"public keys: \n{public_keys}")
    kid = jwt.get_unverified_header(token.replace("Bearer ", ""))["kid"]
    # print(f"kid is {kid}")
    key = public_keys[kid]
    # print(f"key is\n {key}")
    try:
        unverified_token = jwt.get_unverified_header(token.replace("Bearer ", ""))
        return jwt.decode(
            token.replace("Bearer ", ""),
            issuer=ISSUER,
            audience=AAD_APP_CLIENT_ID,
            key=key,
            algorithms=[unverified_token["alg"]],
            options={"verify_signature": True},
        )
    except Exception as e:
        print(e)
        print(traceback.format_exc())
        return None


if __name__ == "__main__":
    print()
    # print("\n\n\n\n")
    parser = argparse.ArgumentParser()
    parser.add_argument("--token", help="JWT token to verify")
    args = parser.parse_args()
    print(verify_jwt(args.token))

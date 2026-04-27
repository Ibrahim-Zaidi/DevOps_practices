from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import qrcode 
import boto3 
import azure
import os
import traceback
from io import BytesIO
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

# --- Static file serving for local fallback ---
os.makedirs("qr_codes", exist_ok=True) 
app.mount("/qr_codes", StaticFiles(directory="qr_codes"), name="qr_codes")

# --- CORS ---
origins = [
    "http://localhost:3000",
    "http://frontend:3000",  
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Conditional S3 setup ---
BACKBLAZE_access_key = os.getenv("BACKBLAZE_ACCESS_KEY")
BACKBLAZE_secret_key = os.getenv("BACKBLAZE_SECRET_KEY")
BACKBLAZE_endpoint = os.getenv("BACKBLAZE_ENDPOINT") 
bucket_name = os.getenv("BUCKET_NAME", "YOUR_BUCKET_NAME")
API_HOST = os.getenv("API_HOST", "http://localhost:8000")  


s3_client = None
if BACKBLAZE_access_key and BACKBLAZE_secret_key:
    s3_client = boto3.client(
        's3',
        # it says AWS but this is a generic s3 client
        aws_access_key_id=BACKBLAZE_access_key,
        aws_secret_access_key=BACKBLAZE_secret_key,
        endpoint_url=BACKBLAZE_endpoint
    )
    print("S3 client initialized using cloud storage")
else:
    print("no BACKBLAZE credentials found !")


@app.post("/generate-qr/")
async def generate_qr(url: str):
    # --- Validate URL minimally ---
    if not url.startswith(("http://", "https://")):
        raise HTTPException(status_code=400, detail="URL must start with http:// or https://")

    # --- Generate QR Code ---
    qr = qrcode.QRCode(version=1, box_size=10, border=4)
    qr.add_data(url)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")

    # Sanitize filename — replace "/" with "_" to avoid path issues
    safe_name = url.split("//")[-1].replace("/", "_")
    file_name = f"{safe_name}.png"

    # --- Upload to S3 or save locally ---
    if s3_client:
        try:
            img_byte_arr = BytesIO() 
            img.save(img_byte_arr, format='PNG') 
            img_byte_arr.seek(0)  
            s3_key = f"qr_codes/{file_name}" 
            s3_client.put_object(
                Bucket=bucket_name,
                Key=s3_key,
                Body=img_byte_arr, 
                ContentType='image/png'
            )
            return {"qr_code_url": f"{BACKBLAZE_endpoint}/{bucket_name}/{s3_key}"}
        except Exception as e:
            traceback.print_exc()
            raise HTTPException(status_code=500, detail=str(e))
    else:
        local_path = f"qr_codes/{file_name}"
        img.save(local_path)
        return {"qr_code_url": f"{API_HOST}/qr_codes/{file_name}"}
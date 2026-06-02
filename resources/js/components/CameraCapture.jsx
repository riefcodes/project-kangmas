import React, { useState, useRef, useCallback, useEffect } from 'react';
import { Camera, RotateCcw, Check, X, Upload, SwitchCamera } from 'lucide-react';

export default function CameraCapture({ onCapture, label, required = false, name, initialFacingMode }) {
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const fileInputRef = useRef(null);

  const [isCameraOpen, setIsCameraOpen] = useState(false);
  const [capturedImage, setCapturedImage] = useState(null);
  const [facingMode, setFacingMode] = useState(initialFacingMode || 'user');
  const [stream, setStream] = useState(null);
  const [error, setError] = useState(null);
  const [mode, setMode] = useState('choose');

  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
    setIsCameraOpen(false);
  }, [stream]);


  useEffect(() => {
    return () => {
      if (stream) {
        stream.getTracks().forEach(track => track.stop());
      }
    };
  }, [stream]);

  const startCamera = useCallback(async (facing = facingMode) => {
    setError(null);
    try {

      if (stream) {
        stream.getTracks().forEach(track => track.stop());
      }

      const constraints = {
        video: {
          facingMode: facing,
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
        audio: false,
      };

      const mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
      setStream(mediaStream);
      setIsCameraOpen(true);
      setMode('camera');

      setTimeout(() => {
        if (videoRef.current) {
          videoRef.current.srcObject = mediaStream;
        }
      }, 100);
    } catch (err) {
      console.error('Camera error:', err);
      if (err.name === 'NotAllowedError') {
        setError('Akses kamera ditolak. Harap izinkan akses kamera di pengaturan browser Anda.');
      } else if (err.name === 'NotFoundError') {
        setError('Kamera tidak ditemukan pada perangkat ini.');
      } else {
        setError('Gagal membuka kamera: ' + err.message);
      }
    }
  }, [facingMode, stream]);

  const switchCamera = useCallback(() => {
    const newFacing = facingMode === 'user' ? 'environment' : 'user';
    setFacingMode(newFacing);
    startCamera(newFacing);
  }, [facingMode, startCamera]);

  const capturePhoto = useCallback(() => {
    if (!videoRef.current || !canvasRef.current) return;

    const video = videoRef.current;
    const canvas = canvasRef.current;

    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;

    const ctx = canvas.getContext('2d');


    if (facingMode === 'user') {
      ctx.translate(canvas.width, 0);
      ctx.scale(-1, 1);
    }

    ctx.drawImage(video, 0, 0);

    canvas.toBlob((blob) => {
      const file = new File([blob], `${name || 'selfie'}_${Date.now()}.jpg`, {
        type: 'image/jpeg',
      });

      const imageUrl = URL.createObjectURL(blob);
      setCapturedImage(imageUrl);
      stopCamera();

      if (onCapture) {
        onCapture(file);
      }
    }, 'image/jpeg', 0.92);
  }, [facingMode, name, onCapture, stopCamera]);

  const retakePhoto = useCallback(() => {
    if (capturedImage) {
      URL.revokeObjectURL(capturedImage);
    }
    setCapturedImage(null);
    onCapture(null);
    startCamera();
  }, [capturedImage, onCapture, startCamera]);

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const imageUrl = URL.createObjectURL(file);
      setCapturedImage(imageUrl);
      setMode('file');
      if (onCapture) {
        onCapture(file);
      }
    }
  };

  const resetAll = () => {
    stopCamera();
    if (capturedImage) {
      URL.revokeObjectURL(capturedImage);
    }
    setCapturedImage(null);
    setMode('choose');
    setError(null);
    if (onCapture) {
      onCapture(null);
    }
  };

  return (
    <div className="camera-capture-wrapper">
      <label className="block text-sm font-semibold text-gray-700 mb-2">
        {label}
      </label>

      {/* Hidden canvas for capture */}
      <canvas ref={canvasRef} style={{ display: 'none' }} />
      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        style={{ display: 'none' }}
      />

      {/* Error message */}
      {error && (
        <div className="bg-red-50 text-red-600 text-sm p-3 rounded-lg border border-red-200 mb-3 flex items-start gap-2">
          <X className="w-4 h-4 mt-0.5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Captured image preview */}
      {capturedImage && !isCameraOpen && (
        <div className="camera-preview-container">
          <div className="camera-captured-result">
            <img src={capturedImage} alt="Captured selfie" className="camera-captured-img" />
            <div className="camera-captured-badge">
              <Check className="w-4 h-4" />
              <span>Foto berhasil diambil</span>
            </div>
          </div>
          <div className="camera-action-row">
            <button type="button" onClick={retakePhoto} className="camera-btn camera-btn-retake">
              <RotateCcw className="w-4 h-4" />
              Ambil Ulang
            </button>
            <button type="button" onClick={resetAll} className="camera-btn camera-btn-cancel">
              <X className="w-4 h-4" />
              Hapus
            </button>
          </div>
        </div>
      )}

      {/* Camera live view */}
      {isCameraOpen && !capturedImage && (
        <div className="camera-preview-container">
          <div className="camera-live-view">
            <video
              ref={videoRef}
              autoPlay
              playsInline
              muted
              className="camera-video"
              style={{ transform: facingMode === 'user' ? 'scaleX(-1)' : 'none' }}
            />
            {/* Guide overlay - different for KTP vs Selfie */}
            {name === 'ktp' ? (
              <div className="camera-guide-overlay">
                <div className="camera-guide-ktp-frame"></div>
                <p className="camera-guide-text">Posisikan KTP dalam bingkai</p>
              </div>
            ) : (
              <div className="camera-guide-overlay camera-guide-selfie-layout">
                <div className="camera-guide-face-circle"></div>
                <div className="camera-guide-ktp-small"></div>
                <p className="camera-guide-text">Posisikan wajah & KTP dalam bingkai</p>
              </div>
            )}
          </div>
          <div className="camera-controls">
            <button type="button" onClick={switchCamera} className="camera-ctrl-btn" title="Ganti Kamera">
              <SwitchCamera className="w-5 h-5" />
            </button>
            <button type="button" onClick={capturePhoto} className="camera-capture-btn" title="Ambil Foto">
              <div className="camera-capture-btn-inner"></div>
            </button>
            <button type="button" onClick={stopCamera} className="camera-ctrl-btn camera-ctrl-cancel" title="Batal">
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>
      )}

      {/* Initial choice buttons */}
      {!isCameraOpen && !capturedImage && (
        <div className="camera-choose-mode">
          <button type="button" onClick={() => startCamera()} className="camera-option-btn camera-option-camera">
            <Camera className="w-5 h-5" />
            <span>Buka Kamera</span>
            <span className="camera-option-sub">Selfie langsung</span>
          </button>
          <button type="button" onClick={() => fileInputRef.current?.click()} className="camera-option-btn camera-option-file">
            <Upload className="w-5 h-5" />
            <span>Pilih File</span>
            <span className="camera-option-sub">Dari galeri</span>
          </button>
        </div>
      )}

      {/* Required hidden input for form validation */}
      {required && !capturedImage && (
        <input
          type="text"
          required
          value=""
          onChange={() => { }}
          className="camera-hidden-required"
          tabIndex={-1}
          aria-hidden="true"
        />
      )}
    </div>
  );
}

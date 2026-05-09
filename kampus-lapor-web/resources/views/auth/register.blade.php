@extends('layouts.auth', ['title' => 'Daftar - Campus Lapor'])

@section('content')
    <section class="auth-shell">
        <main class="auth-form-wrap">
            <form id="register-form" class="auth-form" method="POST" action="{{ route('register.submit') }}" enctype="multipart/form-data">
                @csrf
                <h2>Sign Up</h2>
                <div class="steps">
                    <div class="step active"><span>Daftar Akun Admin</span><span class="dot"></span></div>
                    <div class="step active"><span>Daftar Kampus</span><span class="dot"></span></div>
                    <div class="step"><span>Validasi</span><span class="dot"></span></div>
                </div>

                <input class="field" type="text" name="admin_name" value="{{ old('admin_name') }}" placeholder="Nama admin" required>
                <input class="field" type="email" name="email" value="{{ old('email') }}" placeholder="Email kampus" required>
                <input class="field" type="password" name="password" placeholder="Password" required>
                <input class="field" type="text" name="campus_name" value="{{ old('campus_name') }}" placeholder="Nama kampus" required>
                <input class="field" type="text" name="domain" value="{{ old('domain') }}" placeholder="Domain kampus" required>

                <div class="upload-grid">
                    <label id="campus-photo-upload" class="upload upload-button" for="campus-photo-input">
                        <input id="campus-photo-input" class="file-input" type="file" name="image" accept="image/*">
                        <input id="campus-photo-cropped" type="hidden" name="cropped_image">
                        <span id="campus-photo-label" class="upload-label">Upload foto kampus</span>
                        <img id="campus-photo-preview" class="upload-preview" alt="Preview foto kampus" hidden>
                    </label>
                    <label id="campus-document-upload" class="upload upload-button" for="campus-document-input">
                        <input id="campus-document-input" class="file-input" type="file" name="legal_document" accept="image/*,.pdf">
                        <span id="campus-document-label" class="upload-label">Upload surat legalitas kampus</span>
                    </label>
                </div>

                @if ($errors->any())
                    <p class="hint" style="color: #e34848; font-weight: 800;">{{ $errors->first() }}</p>
                @endif
                <p class="hint">Sudah punya akun admin? <a href="{{ route('login') }}">klik sign in</a></p>
                <div class="actions">
                    <a class="btn" href="{{ route('login') }}">BACK</a>
                    <button class="btn" type="submit">NEXT</button>
                </div>
            </form>
        </main>

        <aside class="auth-panel right">
            <div class="brand">
                <p>Daftarkan kamu sebagai admin, kelola semua laporan di kampusmu.</p>
            </div>
        </aside>
    </section>

    <div id="register-crop-modal" class="crop-modal" hidden>
        <div class="crop-dialog" role="dialog" aria-modal="true" aria-labelledby="register-crop-title">
            <div class="crop-header">
                <h2 id="register-crop-title">Atur Foto Kampus</h2>
                <button class="crop-close" type="button" data-crop-cancel aria-label="Tutup">&times;</button>
            </div>
            <div id="register-crop-frame" class="crop-frame">
                <img id="register-crop-image" alt="Preview foto kampus">
            </div>
            <label class="crop-slider-label" for="register-crop-zoom">Ukuran</label>
            <input id="register-crop-zoom" class="crop-slider" type="range" min="1" max="3" step="0.01" value="1">
            <div class="crop-actions">
                <button class="btn crop-btn outline" type="button" data-crop-cancel>Batal</button>
                <button id="register-crop-apply" class="btn crop-btn" type="button">Pakai Foto</button>
            </div>
        </div>
    </div>

    <style>
        .upload-button {
            position: relative;
            overflow: hidden;
            padding: 0;
            cursor: pointer;
        }

        .upload-button:hover {
            background: rgba(255, 255, 255, .74);
            border-color: var(--purple);
        }

        .file-input {
            position: absolute;
            width: 1px;
            height: 1px;
            opacity: 0;
            pointer-events: none;
        }

        .upload-label {
            z-index: 1;
            padding: 0 12px;
            line-height: 1.25;
        }

        .upload-preview {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .upload.has-preview {
            border-style: solid;
            background: var(--white);
        }

        .upload.has-preview .upload-label {
            position: absolute;
            left: 8px;
            right: 8px;
            bottom: 8px;
            padding: 6px 8px;
            border-radius: 5px;
            background: rgba(36, 24, 61, .74);
            color: var(--white);
        }

        .crop-modal[hidden] {
            display: none;
        }

        .crop-modal {
            position: fixed;
            inset: 0;
            z-index: 30;
            display: grid;
            place-items: center;
            padding: 20px;
            background: rgba(31, 21, 48, .48);
        }

        .crop-dialog {
            width: min(420px, 100%);
            padding: 18px;
            border-radius: 12px;
            background: var(--white);
            box-shadow: 0 18px 42px rgba(31, 21, 48, .25);
        }

        .crop-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-bottom: 16px;
        }

        .crop-header h2 {
            margin: 0;
            color: var(--purple);
            font-size: 20px;
            line-height: 1;
        }

        .crop-close {
            width: 30px;
            height: 30px;
            border: 0;
            border-radius: 50%;
            background: var(--purple-soft);
            color: var(--purple);
            cursor: pointer;
            font-size: 20px;
            line-height: 1;
        }

        .crop-frame {
            position: relative;
            width: 100%;
            aspect-ratio: 2 / 1;
            margin: 0 auto 16px;
            overflow: hidden;
            border: 3px solid #d8c6f1;
            border-radius: 9px;
            background: #f4f0fa;
            cursor: grab;
            touch-action: none;
        }

        .crop-frame:active {
            cursor: grabbing;
        }

        .crop-frame::after {
            content: "";
            position: absolute;
            inset: 0;
            border: 1px solid rgba(255, 255, 255, .72);
            border-radius: 6px;
            pointer-events: none;
        }

        .crop-frame img {
            position: absolute;
            left: 50%;
            top: 50%;
            max-width: none;
            user-select: none;
            pointer-events: none;
            transform-origin: center;
        }

        .crop-slider-label {
            display: block;
            margin-bottom: 8px;
            color: var(--purple);
            font-size: 12px;
            font-weight: 800;
            text-align: left;
        }

        .crop-slider {
            width: 100%;
            accent-color: var(--purple);
        }

        .crop-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 18px;
        }

        .crop-btn {
            min-width: 112px;
        }

        .crop-btn.outline {
            background: var(--purple-soft);
            color: var(--purple);
        }
    </style>

    <script>
        (() => {
            const form = document.getElementById('register-form');
            const photoUpload = document.getElementById('campus-photo-upload');
            const photoInput = document.getElementById('campus-photo-input');
            const croppedInput = document.getElementById('campus-photo-cropped');
            const photoLabel = document.getElementById('campus-photo-label');
            const photoPreview = document.getElementById('campus-photo-preview');
            const documentInput = document.getElementById('campus-document-input');
            const documentLabel = document.getElementById('campus-document-label');
            const modal = document.getElementById('register-crop-modal');
            const frame = document.getElementById('register-crop-frame');
            const image = document.getElementById('register-crop-image');
            const zoomInput = document.getElementById('register-crop-zoom');
            const applyButton = document.getElementById('register-crop-apply');
            const cancelButtons = modal.querySelectorAll('[data-crop-cancel]');

            let objectUrl = null;
            let baseScale = 1;
            let zoom = 1;
            let offsetX = 0;
            let offsetY = 0;
            let startX = 0;
            let startY = 0;
            let startOffsetX = 0;
            let startOffsetY = 0;
            let dragging = false;

            const frameWidth = () => frame.clientWidth;
            const frameHeight = () => frame.clientHeight;

            function clampOffsets() {
                const renderedWidth = image.naturalWidth * baseScale * zoom;
                const renderedHeight = image.naturalHeight * baseScale * zoom;
                const maxX = Math.max(0, (renderedWidth - frameWidth()) / 2);
                const maxY = Math.max(0, (renderedHeight - frameHeight()) / 2);

                offsetX = Math.min(maxX, Math.max(-maxX, offsetX));
                offsetY = Math.min(maxY, Math.max(-maxY, offsetY));
            }

            function renderCrop() {
                clampOffsets();
                image.style.width = `${image.naturalWidth * baseScale}px`;
                image.style.height = `${image.naturalHeight * baseScale}px`;
                image.style.transform = `translate(calc(-50% + ${offsetX}px), calc(-50% + ${offsetY}px)) scale(${zoom})`;
            }

            function openCrop(file) {
                if (objectUrl) {
                    URL.revokeObjectURL(objectUrl);
                }

                objectUrl = URL.createObjectURL(file);
                image.onload = () => {
                    baseScale = Math.max(frameWidth() / image.naturalWidth, frameHeight() / image.naturalHeight);
                    zoom = 1;
                    offsetX = 0;
                    offsetY = 0;
                    zoomInput.value = '1';
                    renderCrop();
                };
                image.src = objectUrl;
                modal.hidden = false;
            }

            function closeCrop(resetFile = false) {
                modal.hidden = true;
                if (resetFile) {
                    photoInput.value = '';
                    croppedInput.value = '';
                }
            }

            function applyCrop() {
                const outputWidth = 960;
                const outputHeight = 480;
                const effectiveScale = baseScale * zoom;
                const sourceWidth = frameWidth() / effectiveScale;
                const sourceHeight = frameHeight() / effectiveScale;
                const sourceX = (image.naturalWidth - sourceWidth) / 2 - (offsetX / effectiveScale);
                const sourceY = (image.naturalHeight - sourceHeight) / 2 - (offsetY / effectiveScale);
                const canvas = document.createElement('canvas');
                const context = canvas.getContext('2d');

                canvas.width = outputWidth;
                canvas.height = outputHeight;
                context.drawImage(
                    image,
                    sourceX,
                    sourceY,
                    sourceWidth,
                    sourceHeight,
                    0,
                    0,
                    outputWidth,
                    outputHeight
                );

                const dataUrl = canvas.toDataURL('image/png', .92);
                croppedInput.value = dataUrl;
                photoPreview.src = dataUrl;
                photoPreview.hidden = false;
                photoUpload.classList.add('has-preview');
                photoLabel.textContent = 'Ganti foto kampus';
                closeCrop();
            }

            photoInput.addEventListener('change', () => {
                const [file] = photoInput.files;
                if (!file) return;
                croppedInput.value = '';
                openCrop(file);
            });

            documentInput.addEventListener('change', () => {
                const [file] = documentInput.files;
                documentLabel.textContent = file ? file.name : 'Upload surat legalitas kampus';
            });

            zoomInput.addEventListener('input', () => {
                zoom = Number(zoomInput.value);
                renderCrop();
            });

            frame.addEventListener('wheel', (event) => {
                event.preventDefault();
                const nextZoom = Math.min(3, Math.max(1, zoom + (event.deltaY > 0 ? -0.05 : 0.05)));
                zoom = nextZoom;
                zoomInput.value = String(nextZoom);
                renderCrop();
            }, { passive: false });

            frame.addEventListener('pointerdown', (event) => {
                dragging = true;
                startX = event.clientX;
                startY = event.clientY;
                startOffsetX = offsetX;
                startOffsetY = offsetY;
                frame.setPointerCapture(event.pointerId);
            });

            frame.addEventListener('pointermove', (event) => {
                if (!dragging) return;
                offsetX = startOffsetX + event.clientX - startX;
                offsetY = startOffsetY + event.clientY - startY;
                renderCrop();
            });

            frame.addEventListener('pointerup', () => {
                dragging = false;
            });

            frame.addEventListener('pointercancel', () => {
                dragging = false;
            });

            applyButton.addEventListener('click', applyCrop);
            cancelButtons.forEach((button) => button.addEventListener('click', () => closeCrop(true)));

            form.addEventListener('submit', () => {
                if (croppedInput.value) {
                    photoInput.removeAttribute('name');
                }
            });
        })();
    </script>
@endsection

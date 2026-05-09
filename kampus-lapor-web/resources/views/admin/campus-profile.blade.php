@extends('layouts.admin', ['title' => 'Profil Kampus', 'active' => 'campus-profile'])

@section('content')
    <div class="topbar">
        <h1>Manajemen Kampus</h1>
        <div class="management-tabs">
            <a class="btn" href="{{ route('campus-profile') }}">Profil Kampus</a>
            <a class="btn outline" href="{{ route('users') }}">Daftar User</a>
        </div>
    </div>

    <section class="panel profile-card">
        <form id="campus-profile-form" class="profile-form" method="POST" action="{{ route('campus-profile.update') }}" enctype="multipart/form-data">
            @csrf
            @method('PATCH')
            @if ($campus->image_path)
                <img id="campus-avatar-preview" class="profile-avatar image" src="{{ asset('storage/'.$campus->image_path) }}" alt="Foto profil {{ $campus->name }}">
            @else
                <span id="campus-avatar-preview" class="profile-avatar"></span>
            @endif
            <label class="btn upload-btn" for="campus-image">Edit Gambar</label>
            <input id="campus-image" class="file-input" type="file" name="image" accept="image/*">
            <input id="cropped-image" type="hidden" name="cropped_image">
            @error('image')
                <span class="form-error">{{ $message }}</span>
            @enderror

            <label>
                Nama Kampus
                <input class="input-line" type="text" name="name" value="{{ old('name', $campus->name) }}">
                @error('name')
                    <span class="form-error">{{ $message }}</span>
                @enderror
            </label>
            <label>
                Domain Kampus
                <input class="input-line" type="text" name="domain" value="{{ old('domain', $campus->domain) }}">
                @error('domain')
                    <span class="form-error">{{ $message }}</span>
                @enderror
            </label>
            <label>
                Daftar Lokasi
                <textarea name="locations">{{ old('locations', $campus->locations->pluck('name')->implode("\n")) }}</textarea>
            </label>
            <button class="btn" type="submit">Simpan</button>
        </form>
    </section>

    <div id="image-crop-modal" class="crop-modal" hidden>
        <div class="crop-dialog" role="dialog" aria-modal="true" aria-labelledby="crop-title">
            <div class="crop-header">
                <h2 id="crop-title">Atur Foto</h2>
                <button class="crop-close" type="button" data-crop-cancel aria-label="Tutup">&times;</button>
            </div>
            <div id="crop-frame" class="crop-frame">
                <img id="crop-image" alt="Preview foto kampus">
            </div>
            <label class="crop-slider-label" for="crop-zoom">Ukuran foto</label>
            <input id="crop-zoom" class="crop-slider" type="range" min="1" max="3" step="0.01" value="1">
            <div class="crop-actions">
                <button class="btn outline" type="button" data-crop-cancel>Batal</button>
                <button id="crop-apply" class="btn" type="button">Pakai Foto</button>
            </div>
        </div>
    </div>

    <style>
        .crop-modal[hidden] {
            display: none;
        }

        .crop-modal {
            position: fixed;
            inset: 0;
            z-index: 20;
            display: grid;
            place-items: center;
            padding: 24px;
            background: rgba(31, 21, 48, .48);
        }

        .crop-dialog {
            width: min(380px, 100%);
            padding: 18px;
            border-radius: 14px;
            background: var(--white);
            box-shadow: 0 18px 40px rgba(31, 21, 48, .24);
        }

        .crop-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
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
            width: 260px;
            height: 260px;
            position: relative;
            margin: 0 auto 18px;
            overflow: hidden;
            border-radius: 50%;
            background: #f4f0fa;
            border: 3px solid #d8c6f1;
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
            border: 1px solid rgba(255, 255, 255, .7);
            border-radius: 50%;
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
    </style>

    <script>
        (() => {
            const form = document.getElementById('campus-profile-form');
            const fileInput = document.getElementById('campus-image');
            const hiddenInput = document.getElementById('cropped-image');
            let preview = document.getElementById('campus-avatar-preview');
            const modal = document.getElementById('image-crop-modal');
            const frame = document.getElementById('crop-frame');
            const image = document.getElementById('crop-image');
            const zoomInput = document.getElementById('crop-zoom');
            const applyButton = document.getElementById('crop-apply');
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

            const frameSize = () => frame.clientWidth;

            function clampOffsets() {
                const renderedWidth = image.naturalWidth * baseScale * zoom;
                const renderedHeight = image.naturalHeight * baseScale * zoom;
                const maxX = Math.max(0, (renderedWidth - frameSize()) / 2);
                const maxY = Math.max(0, (renderedHeight - frameSize()) / 2);

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
                    const size = frameSize();
                    baseScale = Math.max(size / image.naturalWidth, size / image.naturalHeight);
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
                    fileInput.value = '';
                    hiddenInput.value = '';
                }
            }

            function applyCrop() {
                const outputSize = 640;
                const size = frameSize();
                const effectiveScale = baseScale * zoom;
                const sourceSize = size / effectiveScale;
                const sourceX = (image.naturalWidth - sourceSize) / 2 - (offsetX / effectiveScale);
                const sourceY = (image.naturalHeight - sourceSize) / 2 - (offsetY / effectiveScale);
                const canvas = document.createElement('canvas');
                const context = canvas.getContext('2d');

                canvas.width = outputSize;
                canvas.height = outputSize;
                context.drawImage(
                    image,
                    sourceX,
                    sourceY,
                    sourceSize,
                    sourceSize,
                    0,
                    0,
                    outputSize,
                    outputSize
                );

                const dataUrl = canvas.toDataURL('image/png', .92);
                hiddenInput.value = dataUrl;

                if (preview.tagName.toLowerCase() === 'img') {
                    preview.src = dataUrl;
                } else {
                    const img = document.createElement('img');
                    img.id = preview.id;
                    img.className = 'profile-avatar image';
                    img.alt = 'Preview foto kampus';
                    img.src = dataUrl;
                    preview.replaceWith(img);
                    preview = img;
                }

                closeCrop();
            }

            fileInput.addEventListener('change', () => {
                const [file] = fileInput.files;
                if (!file) return;
                hiddenInput.value = '';
                openCrop(file);
            });

            zoomInput.addEventListener('input', () => {
                zoom = Number(zoomInput.value);
                renderCrop();
            });

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
                if (hiddenInput.value) {
                    fileInput.removeAttribute('name');
                }
            });
        })();
    </script>
@endsection

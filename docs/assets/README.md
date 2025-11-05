# Documentation Assets

This folder contains shared assets for the RER-DPG documentation.

---

## 📁 Structure

```
assets/
├── images/          # Documentation images
│   ├── en/         # English-specific images
│   ├── pt-br/      # Portuguese-specific images
│   └── shared/     # Shared images (diagrams, logos)
└── README.md       # This file
```

---

## 🖼️ Images

### Adding Images

1. **Place images** in appropriate folder:
   - Language-specific: `images/en/` or `images/pt-br/`
   - Shared: `images/shared/`

2. **Use descriptive names**: `installation-step-1.png` not `img1.png`

3. **Optimize images**:
   - Use PNG for screenshots
   - Use SVG for diagrams when possible
   - Compress images to reduce size

4. **Reference in Markdown**:
   ```markdown
   ![Installation Step 1](../assets/images/en/installation-step-1.png)
   ```

### Image Guidelines

- **Size**: Keep under 500KB when possible
- **Format**: PNG for screenshots, SVG for diagrams, JPG for photos
- **Alt text**: Always include descriptive alt text
- **Naming**: Use lowercase with hyphens

---

## 🔧 Tools for Image Optimization

```bash
# Install ImageMagick
sudo apt install imagemagick

# Resize image
convert input.png -resize 1200x output.png

# Compress PNG
pngquant input.png --output output.png

# Convert to WebP (modern format)
cwebp -q 80 input.png -o output.webp
```

---

## 📊 Extracting Images from PDFs

When converting PDF manuals to Markdown, extract images:

```bash
# Using pdfimages (from poppler-utils)
pdfimages -png manual.pdf images/prefix

# Using ImageMagick
convert -density 150 manual.pdf[page-number] output.png
```

---

**Back to:** [Documentation Index](../README.md)

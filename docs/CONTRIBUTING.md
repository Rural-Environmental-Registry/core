# Contributing to RER-DPG Documentation

Thank you for your interest in contributing to RER-DPG documentation! This guide will help you get started.

---

## 🌍 Languages

We maintain documentation in two languages:
- **Portuguese (Brazil)** - `docs/pt-br/`
- **English** - `docs/en/`

---

## 📝 How to Contribute

### 1. Documentation Improvements

**For existing Markdown files:**

1. Fork the repository
2. Create a feature branch: `git checkout -b docs/improve-user-manual`
3. Make your changes
4. Commit with clear messages: `git commit -m "docs: improve installation section"`
5. Push and create a Pull Request

**For PDF manuals:**

If you find issues in the PDF manuals, please:
1. Open an issue describing the problem
2. Include page numbers and specific details
3. Suggest corrections if possible

### 2. Converting PDFs to Markdown

We welcome help converting PDF manuals to Markdown format!

**Process:**

1. **Extract content** from PDF (text and images)
2. **Create Markdown files** in appropriate language folder:
   - English: `docs/en/user-manual.md`
   - Portuguese: `docs/pt-br/user-manual.md`
3. **Add images** to `docs/assets/images/`
4. **Format properly** using Markdown syntax
5. **Update links** in `docs/README.md`
6. **Submit PR** with your conversion

**Tools you can use:**
- `pandoc -f pdf -t markdown manual.pdf -o manual.md`
- `pdf2md` - Python tool for PDF to Markdown
- Manual editing for best quality

**Tips:**
- Break content into logical sections
- Use proper heading hierarchy (H1, H2, H3)
- Add alt text to images for accessibility
- Include code blocks with syntax highlighting
- Add navigation links between sections

### 3. Translations

**Adding a new language:**

1. Create folder: `docs/{language-code}/`
2. Copy structure from `docs/en/` or `docs/pt-br/`
3. Translate content
4. Update `docs/README.md` with new language section
5. Submit PR

**Improving existing translations:**

1. Edit files in `docs/pt-br/` or `docs/en/`
2. Ensure technical terms are consistent
3. Submit PR with clear description

### 4. New Documentation

**Adding new guides:**

1. Identify documentation gap
2. Create file in both `docs/en/` and `docs/pt-br/`
3. Follow existing structure and style
4. Add entry to `docs/README.md`
5. Submit PR

---

## ✅ Documentation Standards

### File Naming
- Use lowercase with hyphens: `user-manual.md`
- Be descriptive: `installation-guide.md` not `guide.md`

### Markdown Style
- Use ATX-style headers: `# Header` not `Header\n======`
- Add blank lines around headers and code blocks
- Use fenced code blocks with language: ` ```bash `
- Include alt text for images: `![Description](image.png)`

### Content Guidelines
- Write clear, concise sentences
- Use active voice
- Include examples and code snippets
- Add screenshots when helpful
- Link to related documentation

### Structure
```markdown
# Title

Brief introduction

---

## Section 1

Content...

### Subsection

Content...

---

## Section 2

Content...

---

**Back to:** [Main Documentation](../README.md)
```

---

## 🔍 Review Process

1. **Automated checks** - Markdown linting, link validation
2. **Peer review** - At least one maintainer reviews
3. **Testing** - Verify links and code examples work
4. **Merge** - Approved PRs are merged to main branch

---

## 📋 Commit Message Format

Use conventional commits:

```
docs: add installation guide for Windows
docs: fix broken links in user manual
docs: translate architecture guide to Portuguese
docs(api): update endpoint documentation
```

**Types:**
- `docs:` - Documentation changes
- `fix:` - Fix errors in documentation
- `feat:` - Add new documentation

---

## 🤝 Getting Help

- **Questions?** Open a discussion or issue
- **Stuck?** Ask in your PR, we're happy to help
- **Ideas?** Share them in issues before starting work

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for helping improve RER-DPG documentation! 🎉**

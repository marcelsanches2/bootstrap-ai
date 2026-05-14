#!/usr/bin/env python3
"""
Compara uma imagem de design (Figma) com um screenshot do app Flutter.
Gera uma imagem lado-a-lado com diff destacado.

Uso:
    python3 compare_design.py <figma.png> <flutter.png> <output.png> [--scale-figma=X]
"""

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image, ImageChops, ImageFilter
except ImportError:
    print("Erro: Pillow nao esta instalado. Instale com: pip3 install Pillow")
    sys.exit(1)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Compara design Figma com screenshot Flutter."
    )
    parser.add_argument("figma", help="Caminho para a imagem do Figma")
    parser.add_argument("flutter", help="Caminho para o screenshot do Flutter")
    parser.add_argument("output", help="Caminho para salvar a imagem de comparacao")
    parser.add_argument(
        "--scale-figma",
        type=float,
        default=1.0,
        help="Fator de escala para a imagem do Figma antes da comparacao",
    )
    return parser.parse_args()


def load_image(path: str) -> Image.Image:
    p = Path(path)
    if not p.exists():
        print(f"Erro: arquivo nao encontrado: {path}")
        sys.exit(1)
    img = Image.open(path)
    if img.mode in ("RGBA", "P"):
        # Converte transparencia para fundo branco
        background = Image.new("RGB", img.size, (255, 255, 255))
        if img.mode == "P":
            img = img.convert("RGBA")
        background.paste(img, mask=img.split()[3])  # alpha channel
        img = background
    elif img.mode != "RGB":
        img = img.convert("RGB")
    return img


def resize_with_padding(img: Image.Image, target_size: tuple) -> Image.Image:
    """Redimensiona mantendo proporcao, preenchendo com branco se necessario."""
    target_w, target_h = target_size
    img_ratio = img.width / img.height
    target_ratio = target_w / target_h

    if img_ratio > target_ratio:
        new_w = target_w
        new_h = int(target_w / img_ratio)
    else:
        new_h = target_h
        new_w = int(target_h * img_ratio)

    resized = img.resize((new_w, new_h), Image.Resampling.LANCZOS)

    if (new_w, new_h) == target_size:
        return resized

    padded = Image.new("RGB", target_size, (255, 255, 255))
    x = (target_w - new_w) // 2
    y = (target_h - new_h) // 2
    padded.paste(resized, (x, y))
    return padded


def generate_diff(figma_img: Image.Image, flutter_img: Image.Image) -> Image.Image:
    """Gera imagem de diff destacando diferencas em vermelho."""
    diff = ImageChops.difference(figma_img, flutter_img)
    # Aumenta contraste das diferencas
    diff = diff.point(lambda p: 255 if p > 30 else 0)
    # Cria uma mascara
    grayscale = diff.convert("L")
    # Aplica blur leve para suavizar
    grayscale = grayscale.filter(ImageFilter.GaussianBlur(radius=1))

    # Cria overlay vermelho
    red_overlay = Image.new("RGB", figma_img.size, (255, 0, 0))

    # Mistura o overlay com a imagem Flutter baseado na intensidade da diferenca
    result = flutter_img.copy()
    result = Image.composite(red_overlay, result, grayscale)
    return result


def main():
    args = parse_args()

    figma = load_image(args.figma)
    flutter = load_image(args.flutter)

    # Aplica escala no Figma se solicitado
    if args.scale_figma != 1.0:
        new_size = (
            int(figma.width * args.scale_figma),
            int(figma.height * args.scale_figma),
        )
        figma = figma.resize(new_size, Image.Resampling.LANCZOS)

    # Define o tamanho alvo como o do screenshot Flutter (referencia do device)
    target_size = (flutter.width, flutter.height)

    # Redimensiona Figma para bater com o tamanho do screenshot
    figma_resized = resize_with_padding(figma, target_size)

    # Gera diff
    diff_img = generate_diff(figma_resized, flutter)

    # Monta imagem lado-a-lado: [Figma] | [Flutter] | [Diff]
    total_width = target_size[0] * 3
    total_height = target_size[1]
    combined = Image.new("RGB", (total_width, total_height), (255, 255, 255))

    combined.paste(figma_resized, (0, 0))
    combined.paste(flutter, (target_size[0], 0))
    combined.paste(diff_img, (target_size[0] * 2, 0))

    # Salva resultado
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    combined.save(output_path, "PNG")

    print(f"Comparacao salva em: {output_path}")
    print(f"Dimensoes: {combined.width}x{combined.height}")
    print(f"  [Figma] {figma.width}x{figma.height} -> {target_size[0]}x{target_size[1]}")
    print(f"  [Flutter] {flutter.width}x{flutter.height}")
    print(f"  [Diff] destacado em vermelho")


if __name__ == "__main__":
    main()

# MikA

**MikA**（**M**ikA **i**st **k**eine **A**benteuer-engine）is a GameMaker project template for I Wanna fangame.

## Features

- Moving on any terrains. The moving controller is written in class for reuse and inheritance.
- Mobile blocks and platforms. They can push the player correctly (convex bounding box only).
- Gravity with any direction.
- Class-based trigger.

> [!Caution]
> This engine breaks the low-level architecture on which the traditional I Wanna engine is based (like Yuuutu). The differences include but are not limited to:
>
> 1. **Aligns will not work.** Everything related to aligns like x-align, y-align and bunny hopping will not work any more.
> 1. **Platforms will not pull the player up.** In traditional engines, the player will get an extra jump if it collides with platforms. Platforms will also pull the player up if there is enough space. In our project, platforms only serve as one-way-through floors. There is no extra jump and no pulling up.

## Roadmap

- Implement all common elements in I Wanna.

> [!Note]
>
> This project is for personal use now, so the update may be very slow.

> [!WARNING]
> This project only supports GameMaker with the newest version (tested on `IDE=2024.4.1.152, RUNTIME=2024.4.1.202`). GameMaker: Studio 1 and GameMaker 8.0 are **not** supported.

Feel free to open an issue if you find any bugs or need any new features.

<div align="center">
    <img src="Mika.jpg" alt="MikA" />
</div>



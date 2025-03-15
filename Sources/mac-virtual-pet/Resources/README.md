# Pixel Art Character Resources

This directory contains animated GIF images for the pet application.

## Directory Structure

Each character should have its own directory named after the character. For example, the default "pet" character has its images in the `pet` directory.

## Required Images

Each character directory should contain the following GIF images:

- `sit.gif`: Animation for the sitting state
- `walk.gif`: Animation for the walking state

The GIFs should be transparent and have consistent dimensions. The walking GIF will be automatically flipped horizontally when the character walks to the left.

## Running with Different Characters

To run the application with a different character, pass the character name as a command line argument:

```
./.build/debug/Virtual\ Pet dog
```

This will look for GIF images in the `Resources/dog` directory. 

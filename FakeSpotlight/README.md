# Fake Spotlight v0.1.3a

Just a simple shader using a grab pass and some stencils to create the appearance of a spotlight. As it is not a real light, it will not work in complete darkness, as it is just multiplying the intensity of whatever you see. A result of this is that the brightness of the spotlight is relative to how dark or bright the objects its shining on are, as it is multiplicative. Because it is not real spotlight, it does not cast shadows, does not get occluded by objects, or have its brightness fall off over distance. It also comes with a few simple color adjustment settings. However, just because it is not a real light doesn't mean you should use this freely, as it still uses a Grab Pass. This is not meant to be any sort of replacement for spotlights, I'm just using this for a gimmick, but maybe someone else might have a use for it.

For the record I'm still quite inexperienced with Shaders so this is probably quite terribly written.

### Shader Types

- FakeSpotlight - Regular version using grabpass for various effects
- FakeSpotlightNoGrabPass - Version without grabpass, only has color tinting. 

### Shader settings

- Color Tint - Tints the color of the light
- Light Angle Override - Overrides the angle of the spotlight. Keep in mind adjusting the spotlight mesh should be a first choice as this won't affect the bounding box of the spotlight mesh and thus may cause occlusion issues.
- Light Distance Override - Overrides the distance of the spotlight. Keep in mind the same as above.
- Dark Light - Changes light so it darkens instead. Brightness of 1 is pitch black.
- Brightness - The intensity of the light
- Brightness Multiplier - Multiplier for the above intensity
- Hue - Hue shift function
- Saturation - 0 - black and white, 1 - normal, 2 - doubled saturation
- Contrast - 0.5 - 1.5 Contrast range
- White balance (Temperature) - blue/yellow color shift
- White balance (Tint) - pink/green color shift
- Enable Mosaic - Simple mosaic filter
- Mosaic block size - Size/number of blocks for the mosaic
- Stencil ID - This shader uses a stencil to achieve the spotlight effect, so just pick a number between 1-255 to reduce chance of conflict with other shaders using stencils

# Caveats

- Does not work in completely dark scenes
- Cannot overlap lights if they have different settings
- Doesn't work on some transparent shaders
- Shader code is a bit inefficient

# Update History

#### 28th Mar 2021

- Minor fixes

#### 4th Feb 2021

- Added a simplified variant without a grab pass, with just color tinting and the light can only make objects twice as bright.

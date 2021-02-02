# VRChat odds and ends

Just a collection of various VRChat related things I've made. Items here are probably not going to be very polished, and are mostly just experiments I've been tinkering around with. 

--- 
# Fake Spotlight

Just a simple shader using a grab pass and some stencils to create the appearance of a spotlight. As it is not a real light, it will not work in complete darkness, and requires some existing light to amplify it. Unlike a real spotlight, it does not cast shadows, or have its brightness fall off over distance. Unlike a real spotlight, you can use it to do some simple post process effects. However, just because it is not a real light doesn't mean you should use this freely, as it still uses a Grab Pass. I'm just using this for a gimmick, but maybe someone else might have a use for it.

For the record I'm still quite inexperienced with Shaders so this is probably quite terribly written.

### Shader settings
- Color Tint - Tints the color of the light
- Light Angle Override - Overrides the angle of the spotlight. Keep in mind adjusting the spotlight mesh should be a first choice as this won't affect the bounding box of the light and thus may cause occlusion issues.
- Light Distance Override - Overrides the distance of the spotlight. Keep in mind the same as above.
- Dark Light - Turns the light into something that darkens instead.
- Brightness - The intensity of the light
- Brightness Multiplier - Multiplier for the above intensity
- Saturation - Saturation post process effect
- Contrast - Contrast post process effect
- White balance (Temperature) - Temperature adjustment for white balance post process
- White balance (Tint) - Tint adjustment for whtie balance post process
- Stencil ID - This shader uses a stencil to achieve the spotlight effect, so just pick a number between 1-255 to reduce chance of conflict with other shaders using stencils

#### [Download Fake Spotlight](https://github.com/acertainbluecat/VRChat-odds-and-ends/releases/download/unitypackages/FakeSpotlight_v0.1.unitypackage)  
![Fake Spotlight](https://nyanpa.su/i/wCic1dEj.jpg)
---

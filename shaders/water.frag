#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uRippleCount;
uniform vec3 uRipples[10];

out vec4 fragColor;

// Fast value noise
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
    vec2 fc = FlutterFragCoord().xy;
    vec2 uv = fc / uResolution;

    // --- 1. REALISTIC DEEP WATER BACKGROUND ---
    // Rich depth gradient with teal/blue tones
    vec3 deepBlue   = vec3(0.008, 0.035, 0.09);
    vec3 midBlue    = vec3(0.015, 0.06, 0.14);
    vec3 darkTeal   = vec3(0.01, 0.05, 0.10);
    
    vec3 baseColor = mix(midBlue, deepBlue, uv.y);
    
    // Subtle color variation (underwater light patches)
    float colorVar = vnoise(vec2(fc.x * 0.003 + uTime * 0.02, fc.y * 0.003));
    baseColor += vec3(0.005, 0.015, 0.025) * colorVar;

    // --- 2. UNDERWATER CAUSTIC PATTERNS ---
    // Moving light patterns on the "floor" of shallow water
    float c1 = vnoise(vec2(fc.x * 0.008 + uTime * 0.12, fc.y * 0.006 - uTime * 0.08));
    float c2 = vnoise(vec2(fc.x * 0.01 - uTime * 0.09, fc.y * 0.012 + uTime * 0.06));
    float caustic = c1 * c2;
    caustic = pow(caustic, 2.5) * 0.12;
    baseColor += vec3(0.04, 0.10, 0.16) * caustic;

    // --- 3. RIPPLE WAVES ---
    float totalHeight = 0.0;
    vec2 totalGrad = vec2(0.0);
    int count = min(int(uRippleCount), 10);

    for (int i = 0; i < 10; i++) {
        if (i >= count) break;
        vec2 center = uRipples[i].xy;
        float startT = uRipples[i].z;
        
        float age = uTime - startT;
        if (age < 0.0 || age > 4.0) continue;

        float dist = length(fc - center);
        float speed = 160.0;
        float waveLen = 35.0;
        float waveR = age * speed;
        
        // Wave envelope (ring shape)
        float waveDist = dist - waveR;
        float envelope = exp(-waveDist * waveDist / (waveLen * waveLen * 3.0));
        
        // Decay
        float decay = exp(-age * 0.7);
        float distDecay = 1.0 / (1.0 + dist * 0.004);
        
        // Multiple concentric rings (fundamental + harmonic)
        float phase1 = (dist - waveR) / waveLen * 6.28318;
        float phase2 = (dist - waveR) / (waveLen * 0.6) * 6.28318;
        float wave = sin(phase1) * 0.7 + sin(phase2) * 0.3;
        wave *= envelope * decay * distDecay;
        
        totalHeight += wave;
        
        // Gradient for lighting
        vec2 dir = (dist > 0.5) ? (fc - center) / dist : vec2(0.0);
        float grad = cos(phase1) * 0.7 + cos(phase2) * 0.3;
        totalGrad += dir * grad * envelope * decay * distDecay;
    }

    // --- 4. WAVE LIGHTING (realistic surface reflection) ---
    vec2 lightDir = normalize(vec2(-0.4, -1.0));
    float lightI = dot(normalize(totalGrad + vec2(0.001)), lightDir);
    
    // Bright specular highlights (like real water surface)
    float specular = pow(max(lightI, 0.0), 6.0) * length(totalGrad) * 0.6;
    
    // Soft diffuse from wave height
    float diffuse = totalHeight * 0.06;
    
    // Apply realistic water highlight colors (white-ish with slight blue)
    vec3 highlight = vec3(0.5, 0.7, 0.9);
    baseColor += diffuse * vec3(0.02, 0.04, 0.08);
    baseColor += highlight * specular;
    
    // Dark troughs
    baseColor += min(totalHeight, 0.0) * vec3(0.01, 0.02, 0.03) * 0.4;

    // --- 5. SUBTLE SURFACE TEXTURE ---
    float surfNoise = (vnoise(vec2(fc.x * 0.01 + uTime * 0.03, fc.y * 0.01)) - 0.5) * 0.01;
    baseColor += surfNoise;

    // Soft vignette
    float vig = 1.0 - length((uv - 0.5) * 1.4);
    vig = smoothstep(0.0, 0.7, vig);
    baseColor *= 0.85 + 0.15 * vig;

    baseColor = clamp(baseColor, 0.0, 1.0);
    fragColor = vec4(baseColor, 1.0);
}

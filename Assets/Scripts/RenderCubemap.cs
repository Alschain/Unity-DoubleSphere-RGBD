// Copyright Massachusetts Institute of Technology 2018

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class RenderCubemap : MonoBehaviour {
    public RenderTexture color_cubemap;
    public RenderTexture depth_cubemap;

    public void Initialize(DoubleSphereTemplate template) {
        color_cubemap = new RenderTexture(template.resolution, template.resolution, 32, RenderTextureFormat.ARGBFloat);
        color_cubemap.dimension = TextureDimension.Cube;
        color_cubemap.hideFlags = HideFlags.HideAndDontSave;
        GetComponent<Camera>().nearClipPlane = 0.01f;
        GetComponent<Camera>().farClipPlane = 10.0f;
        GetComponent<Camera>().RenderToCubemap(color_cubemap);
        GetComponent<Camera>().enabled = false;

        depth_cubemap = new RenderTexture(template.resolution, template.resolution, 32, RenderTextureFormat.ARGBFloat);
        depth_cubemap.dimension = TextureDimension.Cube;
        depth_cubemap.hideFlags = HideFlags.HideAndDontSave;
        GetComponent<Camera>().SetReplacementShader(Shader.Find("Custom/CubemapDepth"), null);
        GetComponent<Camera>().RenderToCubemap(depth_cubemap);
    }
    

    void Update()
    {
        GetComponent<Camera>().SetReplacementShader(Shader.Find("Standard"), null);
        GetComponent<Camera>().RenderToCubemap(color_cubemap);
        GetComponent<Camera>().SetReplacementShader(Shader.Find("Custom/CubemapDepth"), null);
        GetComponent<Camera>().RenderToCubemap(depth_cubemap);
    }

}
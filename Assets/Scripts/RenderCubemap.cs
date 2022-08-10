// Copyright Massachusetts Institute of Technology 2018

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class RenderCubemap : MonoBehaviour {
    public RenderTexture color_cubemap;
    public RenderTexture depth_cubemap;

    public void Initialize()
    {
        color_cubemap = new RenderTexture(2048, 2048,32, RenderTextureFormat.ARGBFloat);
        color_cubemap.dimension = TextureDimension.Cube;
        color_cubemap.hideFlags = HideFlags.HideAndDontSave;
        GetComponent<Camera>().nearClipPlane = 0.01f;
        GetComponent<Camera>().farClipPlane = 10.0f;
        // GetComponent<Camera>().stereoSeparation = 0f;
        GetComponent<Camera>().RenderToCubemap(color_cubemap, 63, Camera.MonoOrStereoscopicEye.Left);
        GetComponent<Camera>().enabled = false;

        depth_cubemap = new RenderTexture(2048, 2048,32, RenderTextureFormat.ARGBFloat);
        depth_cubemap.dimension = TextureDimension.Cube;
        depth_cubemap.hideFlags = HideFlags.HideAndDontSave;
        GetComponent<Camera>().SetReplacementShader(Shader.Find("Custom/CubemapDepth"), null);
        GetComponent<Camera>().RenderToCubemap(depth_cubemap, 63, Camera.MonoOrStereoscopicEye.Left);
    }


    public void LocalUpdate()
    {
        GetComponent<Camera>().SetReplacementShader(Shader.Find("Standard"), null);
        GetComponent<Camera>().RenderToCubemap(color_cubemap, 63, Camera.MonoOrStereoscopicEye.Left);
        GetComponent<Camera>().SetReplacementShader(Shader.Find("Custom/CubemapDepth"), null);
        GetComponent<Camera>().RenderToCubemap(depth_cubemap, 63, Camera.MonoOrStereoscopicEye.Left);
    }

}
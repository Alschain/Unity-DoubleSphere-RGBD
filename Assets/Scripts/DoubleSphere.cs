using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System.IO;

public class DoubleSphere : MonoBehaviour {
    public RenderCubemap cubemap;
	public DoubleSphereTemplate template;

	void Start()
	{
		cubemap = this.transform.GetChild(0).gameObject.AddComponent<RenderCubemap>();
		cubemap.Initialize(template);
		GetComponent<Camera>().targetTexture = new RenderTexture(template.resolution, template.resolution, 32, RenderTextureFormat.ARGBFloat);
	}


    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Material mt = new Material(Shader.Find("Custom/DoubleSphere"));
        mt.hideFlags = HideFlags.HideAndDontSave;
        mt.SetTexture("_ColorCube", cubemap.color_cubemap);
        mt.SetTexture("_DepthCube", cubemap.depth_cubemap);
        mt.SetFloat("_Alpha", template.alpha);
        mt.SetFloat("_Chi", template.chi);
        mt.SetFloat("_fx", template.fx);
        mt.SetFloat("_fy", template.fy);
		mt.SetFloat("_Resolution", template.resolution);
        Graphics.Blit(source, destination, mt);

    }
}
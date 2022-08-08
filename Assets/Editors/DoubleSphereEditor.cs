using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(DoubleSphereTemplate))]
public class DoubleSphereEditor : Editor
{
	public override void OnInspectorGUI()
	{
		//
		DrawDefaultInspector();

		//
		if (GUILayout.Button("Generate"))
		{
			//
			DoubleSphereTemplate template = (DoubleSphereTemplate)target;

			//
			GameObject prefab = new GameObject();
			prefab.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);
			prefab.transform.localScale = Vector3.one;

			//
			GameObject reference = new GameObject("Cubemap");
			reference.transform.parent = prefab.transform;
			reference.transform.SetPositionAndRotation(Vector3.zero, Quaternion.identity);
			reference.transform.localScale = Vector3.one;

			
			Camera referenceCam = reference.AddComponent<Camera>();
			referenceCam.transform.parent = reference.transform;

			Camera prefabCamera = prefab.AddComponent<Camera>();


			//
			DoubleSphere doubleSphere = prefab.AddComponent<DoubleSphere>();
			doubleSphere.template = template;

            string path = AssetDatabase.GetAssetPath(target);
            string name = path.Substring(path.LastIndexOf('/') + 1);
            name = name.Substring(0, name.LastIndexOf('.'));
			
		    path = path.Substring(0, path.LastIndexOf('/'));

            //
			PrefabUtility.SaveAsPrefabAsset(prefab, path + "/" + name + ".prefab");
			GameObject.DestroyImmediate(prefab);
			AssetDatabase.SaveAssets();
		}
	}
}
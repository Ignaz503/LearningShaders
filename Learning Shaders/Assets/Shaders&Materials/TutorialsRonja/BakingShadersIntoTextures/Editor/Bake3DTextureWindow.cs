using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;

public class Bake3DTextureWindow : EditorWindow
{
    [MenuItem("Tools/Bake material to 3D texture")]
    static void OpenWindow()
    {
        Bake3DTextureWindow window = EditorWindow.GetWindow<Bake3DTextureWindow>();
        window.Show();
        window.changed = true;
    }

    Material materialToBake;
    string filePath = "Assets/Resources/materialImage.asset";

    Vector3Int imageResolution;

    bool changed;

    bool _hasValidMaterial;
    bool hasValidMaterial
    {
        get
        {
            if (changed)
            {
                _hasValidMaterial = materialToBake != null && materialToBake.HasProperty("_Height");
            }
            return _hasValidMaterial;
        }
    }

    bool _HasValidResolution;
    bool hasValidResolution
    {
        get
        {
            if (changed)
                _HasValidResolution = imageResolution.x != 0 && imageResolution.y != 0 && imageResolution.z != 0;
            return _HasValidResolution;
        }
    }

    bool _hasValidFile = true;
    bool hasValidFile
    {
        get
        {
            if (changed)
            {
                try
                {
                    string ext = Path.GetExtension(filePath);
                    _hasValidFile = ext.Equals(".asset");

                }
                catch (ArgumentException)
                {
                    _hasValidFile = false;
                }
            }
            return _hasValidFile;
        }
    }

    private void OnGUI()
    {
        EditorGUILayout.HelpBox("Set the material, set a resolution of the image you want and add the path where you want to save the file to. After that click bake and watch your texture being created", MessageType.Info);

        using (var check = new EditorGUI.ChangeCheckScope())
        {
            materialToBake = (Material)EditorGUILayout.ObjectField("Material: ", materialToBake, typeof(Material), false);

            imageResolution = EditorGUILayout.Vector3IntField("Image Resolution: ", imageResolution);

            filePath = FileField(filePath);
            changed = check.changed;
        }

        GUI.enabled = hasValidMaterial && hasValidFile && hasValidResolution;
        if (GUILayout.Button("Bake"))
        {
            //Bake
            Bake();
        }
        GUI.enabled = true;

        ShowWarnings();
    }

    string FileField(string currentPath)
    {
        EditorGUILayout.LabelField("Output File");
        using (new GUILayout.HorizontalScope())
        {
            currentPath = EditorGUILayout.TextField(currentPath);
            if (GUILayout.Button("Choose"))
            {
                string directory = "Assets/Resources";
                string fileName = "materialImage.asset";

                try
                {
                    directory = Path.GetDirectoryName(currentPath);
                    fileName = Path.GetFileName(currentPath);
                }
                catch (ArgumentException) { }

                string chosenFile = EditorUtility.SaveFilePanelInProject("Choose image file", fileName, "asset", "Please enter a file name to save the image to", directory);

                if (!string.IsNullOrEmpty(chosenFile))
                {
                    currentPath = chosenFile;
                }
                Repaint();
            }
        }
        return currentPath;
    }


    void ShowWarnings()
    {
        if (!hasValidMaterial)
            EditorGUILayout.HelpBox("You are missing a material, or the material has no proptery of name height to generate slices", MessageType.Warning);

        if (!hasValidResolution)
            EditorGUILayout.HelpBox("Your resolution needs to be bigger than zero", MessageType.Warning);

        if (!hasValidFile)
            EditorGUILayout.HelpBox("No file to save image to given", MessageType.Warning);
    }

    private void Bake()
    {
        RenderTexture tempRender = RenderTexture.GetTemporary(imageResolution.x, imageResolution.y);
        RenderTexture.active = tempRender;

        Texture3D volumeTexture = new Texture3D(imageResolution.x, imageResolution.y, imageResolution.z, TextureFormat.ARGB32, false);
        Texture2D tempTex = new Texture2D(imageResolution.x, imageResolution.y);

        //loop slices and write

        int voxelAmount = imageResolution.x * imageResolution.y * imageResolution.z;
        int slicePixelAmount = imageResolution.x * imageResolution.y;

        Color32[] colors = new Color32[voxelAmount];

        for (int slice = 0; slice < imageResolution.z; slice++)
        {
            float height = (slice + .5f) / imageResolution.z;
            materialToBake.SetFloat("_Height", height);

            Graphics.Blit(null, tempRender, materialToBake);
            tempTex.ReadPixels(new Rect(0, 0, imageResolution.x, imageResolution.y), 0, 0);
            Color32[] sliceColors = tempTex.GetPixels32();

            int sliceBasIdx = slice * slicePixelAmount;
            for (int pixel = 0; pixel < slicePixelAmount; pixel++)
            {
                colors[sliceBasIdx + pixel] = sliceColors[pixel];
            }

        }

        //save
        volumeTexture.SetPixels32(colors);
        AssetDatabase.CreateAsset(volumeTexture, filePath);

        //cleanup
        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(tempRender);
        //DestroyImmediate(volumeTexture);
        DestroyImmediate(tempTex);
    }
}

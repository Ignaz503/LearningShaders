using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;

public class BakeTextureWindow : EditorWindow
{
    [MenuItem("Tools/Bake material to texture")]
    static void OpenWindow()
    {
        BakeTextureWindow window = EditorWindow.GetWindow<BakeTextureWindow>();
        window.Show();
        window.changed = true;
    }

    Material materialToBake;
    string filePath = "Assets/Resources/materialImage.png";

    Vector2Int imageResolution;

    bool changed;

    bool _hasValidMaterial;
    bool hasValidMaterial {
        get
        {
            if(changed)
                _hasValidMaterial =  materialToBake != null;
            return _hasValidMaterial;
        }
    }

    bool _HasValidResolution;
    bool hasValidResolution {
        get
        {
            if(changed)
                _HasValidResolution =  imageResolution.x != 0 && imageResolution.y != 0;
            return _HasValidResolution;
        }
    }

    bool _hasValidFile = true;
    bool hasValidFile {
        get
        {
            if (changed)
            {
                try
                {
                    string ext = Path.GetExtension(filePath);
                    _hasValidFile = ext.Equals(".png");

                }catch(ArgumentException)
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
            materialToBake = (Material)EditorGUILayout.ObjectField("Material: ",materialToBake,typeof(Material),false);

            imageResolution = EditorGUILayout.Vector2IntField("Image Resolution: ", imageResolution);

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
                string fileName = "materialImage.png";

                try
                {
                    directory = Path.GetDirectoryName(currentPath);
                    fileName = Path.GetFileName(currentPath);
                }
                catch (ArgumentException) { }

                string chosenFile = EditorUtility.SaveFilePanelInProject("Choose image file", fileName, "png", "Please enter a file name to save the image to", directory);

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
            EditorGUILayout.HelpBox("You are missing a material", MessageType.Warning);

        if (!hasValidResolution)
            EditorGUILayout.HelpBox("Your resolution needs to be bigger than zero", MessageType.Warning);

        if (!hasValidFile)
            EditorGUILayout.HelpBox("No file to save image to given", MessageType.Warning);
    }

    private void Bake()
    {
        RenderTexture temp = RenderTexture.GetTemporary(imageResolution.x, imageResolution.y);
        Graphics.Blit(null, temp, materialToBake);

        Texture2D image = new Texture2D(imageResolution.x,imageResolution.y);
        RenderTexture.active = temp;
        image.ReadPixels(new Rect(Vector2.zero, imageResolution), 0, 0);

        byte[] png = image.EncodeToPNG();
        File.WriteAllBytes(filePath, png);
        AssetDatabase.Refresh();

        //cleanup
        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(temp);
        DestroyImmediate(image);

    }
}

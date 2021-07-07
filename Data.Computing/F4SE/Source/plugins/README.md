# Quick Checklist
- Project-Property for D4SE plugins path on VS `project.user` file. This is hand edited xml.
- Switch libraries to static.
- Compile in Debug mode.
- Xtensions: LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS` on the project preprocessers. 
- Use "Steamless" to strip Fallout4.exe DRM for debugger support.
- Produce a PDB for Fallout4.exe using the tool I forgot. I get the feeling it only produces a minimal blank PDB.



# Setup
```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <Fallout4Path>E:\Bethesda\steamapps\common\Fallout 4</Fallout4Path>
  </PropertyGroup>
</Project>
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <Fallout4Path>E:\Bethesda\steamapps\common\Fallout 4\Data\F4SE\Plugins</Fallout4Path>
  </PropertyGroup>
</Project>
```

# Debugging
??? lol

# Releasing
??? lol



﻿#Magic C# code
$code = ' 
    using System; 
    using System.Drawing; 
    using System.Runtime.InteropServices; 
 using System.IO; 
     
    namespace System { 
        public class IconExtractor { 
            public static Icon Extract(string file, int number, bool largeIcon) { 
                IntPtr large; 
                IntPtr small; 
                ExtractIconEx(file, number, out large, out small, 1); 
                try { return Icon.FromHandle(largeIcon ? large : small); } 
                catch { return null; } 
            } 
            [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)] 
            private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons); 
        } 
    } 
  
 public class PngIconConverter 
    { 
        public static bool Convert(System.IO.Stream input_stream, System.IO.Stream output_stream, int size, bool keep_aspect_ratio = false) 
        { 
            System.Drawing.Bitmap input_bit = (System.Drawing.Bitmap)System.Drawing.Bitmap.FromStream(input_stream); 
            if (input_bit != null) 
            { 
                int width, height; 
                if (keep_aspect_ratio) 
                { 
                    width = size; 
                    height = input_bit.Height / input_bit.Width * size; 
                } 
                else 
                { 
                    width = height = size; 
                } 
                System.Drawing.Bitmap new_bit = new System.Drawing.Bitmap(input_bit, new System.Drawing.Size(width, height)); 
                if (new_bit != null) 
                { 
                    System.IO.MemoryStream mem_data = new System.IO.MemoryStream(); 
                    new_bit.Save(mem_data, System.Drawing.Imaging.ImageFormat.Png); 
 
                    System.IO.BinaryWriter icon_writer = new System.IO.BinaryWriter(output_stream); 
                    if (output_stream != null && icon_writer != null) 
                    { 
                        icon_writer.Write((byte)0); 
                        icon_writer.Write((byte)0); 
                        icon_writer.Write((short)1); 
                        icon_writer.Write((short)1); 
                        icon_writer.Write((byte)width); 
                        icon_writer.Write((byte)height); 
                        icon_writer.Write((byte)0); 
                        icon_writer.Write((byte)0); 
                        icon_writer.Write((short)0); 
                        icon_writer.Write((short)32); 
                        icon_writer.Write((int)mem_data.Length); 
                        icon_writer.Write((int)(6 + 16)); 
      icon_writer.Write(mem_data.ToArray()); 
      icon_writer.Flush(); 
                        return true; 
                    } 
                } 
                return false; 
            } 
            return false; 
        } 
 
        public static bool Convert(string input_image, string output_icon, int size, bool keep_aspect_ratio = false) 
        { 
            System.IO.FileStream input_stream = new System.IO.FileStream(input_image, System.IO.FileMode.Open); 
            System.IO.FileStream output_stream = new System.IO.FileStream(output_icon, System.IO.FileMode.OpenOrCreate); 
 
            bool result = Convert(input_stream, output_stream, size, keep_aspect_ratio); 
 
            input_stream.Close(); 
            output_stream.Close(); 
 
            return result; 
        } 
    } 
'

#making the magic C# code work in PS
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing, System.IO -ErrorAction SilentlyContinue


#variables
$lnkpath="C:\lnks"
$size=32
$type="ico"
$directory="C:\Icons"

$lnks= Get-ChildItem -Path $lnkpath -include *.lnk -Recurse

foreach($lnk in $lnks)
{
    $path = $lnk.FullName

    #Getting Shortcut Information
    $Shell = New-Object -ComObject ("WScript.Shell")
    $Shortcut = $Shell.CreateShortcut($path)
    $Iconpath=$Shortcut.IconLocation.Split(',')[0]
    if($Iconpath.Length -eq 0)
    {
        $Iconpath=$Shortcut.TargetPath 
    }
    $Iconindex=$Shortcut.IconLocation.Split(',')[1]


    #Creates Icon file for shortcut
    $basename = [io.path]::GetFileNameWithoutExtension($Iconpath)
    $filepath = "$directory\$basename-$Iconindex.$type"
    $icon = [System.IconExtractor]::Extract($Iconpath, $Iconindex, $true)
    $bmp = $icon.ToBitmap()
    $tempfile = "$directory\tempicon.png"
    $bmp.Save($tempfile,"png")
    [PngIconConverter]::Convert($tempfile,$filepath,$size,$true) | Out-Null
    Remove-Item $tempfile -Force
}



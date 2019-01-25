#Magic C# code
#PngIconConverter
$PngIconConverter = ' 
    using System; 
    using System.Drawing; 
    using System.Runtime.InteropServices; 
 using System.IO;  
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
Add-Type -TypeDefinition $PngIconConverter -ReferencedAssemblies System.Drawing, System.IO -ErrorAction SilentlyContinue

#add-type -AssemblyName System.Drawing


$srcFile="C:\Icon.png"
$outFile="$($srcfile.split('.')[0]).ico"
$png = New-Object System.Drawing.Bitmap $srcFile
$size=$png.width
$png.Dispose()


[PngIconConverter]::Convert($srcFile,$outFile,$size,$true) | Out-Null
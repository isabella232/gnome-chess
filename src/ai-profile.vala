/*
 * Copyright (C) 2010-2013 Robert Ancell
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class AIProfile
{
    public string name;
    public string protocol;
    public string binary;
    public string path;
    public string[] easy_args;
    public string[] normal_args;
    public string[] hard_args;
    public string[] easy_options;
    public string[] normal_options;
    public string[] hard_options;
}

public List<AIProfile> load_ai_profiles (string filename)
{
   var profiles = new List<AIProfile> ();

   var file = new KeyFile ();
   try
   {
       file.load_from_file (filename, KeyFileFlags.NONE);
   }
   catch (KeyFileError e)
   {
       warning ("Failed to load AI profiles: %s", e.message);
       return profiles;   
   }
   catch (FileError e)
   {
       warning ("Failed to load AI profiles: %s", e.message);
       return profiles;
   }

   foreach (string name in file.get_groups ())
   {
       debug ("Loading AI profile %s", name);
       var profile = new AIProfile ();
       try
       {
           profile.name = name;
           profile.protocol = file.get_value (name, "protocol");
           profile.binary = file.get_value (name, "binary");

           profile.easy_args = load_array (file, name, "arg", "easy");
           profile.normal_args = load_array (file, name, "arg", "normal");
           profile.hard_args = load_array (file, name, "arg", "hard");
           profile.easy_options = load_array (file, name, "option", "easy");
           profile.normal_options = load_array (file, name, "option", "normal");
           profile.hard_options = load_array (file, name, "option", "hard");
       }
       catch (KeyFileError e)
       {
           continue;
       }

       var path = Environment.find_program_in_path (profile.binary);
       if (path != null)
       {
           profile.path = path;
           profiles.append (profile);
       }
   }

   return profiles;
}

private string[] load_array (KeyFile file, string name, string type, string difficulty) throws KeyFileError
{
    int count = 0;
    while (file.has_key (name, "%s-%s-%d".printf (type, difficulty, count)))
        count++;

    string[] options = new string[count];
    for (var i = 0; i < count; i++)
        options[i] = file.get_value (name, "%s-%s-%d".printf (type, difficulty, i));

    return options;
}

using System;
using System.IO;
using System.Threading;

class FileRW {
    static Random random;

    static int Main(string[] args) {
        const int RETURN_SUCCESS = 0;
        const int ERROR_ARGUMENTS_INCORRECT = 1;
        const int ERROR_FILE_NOT_FOUND = 10;
        const int ERROR_TIME_PARSE_ERR = 11;
        const int ERROR_SLEEP_PARSE_ERR = 12;

        DateTime startTime;
        DateTime endTime;
        DateTime startTime2;
        DateTime endTime2;

        random = new Random();

        if (args.Length == 0 || args.Length > 3) {
            Console.WriteLine("FileRW.exe {FileName} {Time} {Sleep}");
            return ERROR_ARGUMENTS_INCORRECT;
        }

        /* Parse the Command Line in (possibly) the most ugly way possible */
        string fpath = (args.Length > 0) ? args[0] : @"C:\test.txt";
        string ftime = (args.Length > 1) ? args[1] : "100";
        string fsleep = (args.Length > 2) ? args[2] : "100";
        int time = 0;
        int loops = 0;
        int sleep = 1;

        if (!File.Exists(fpath)) {
            Console.WriteLine("File must exist {0}", fpath);
            return ERROR_FILE_NOT_FOUND;
        }
        if (!Int32.TryParse(ftime, out time)) {
            Console.WriteLine("Cannot parse time from {0}", ftime);
            return ERROR_TIME_PARSE_ERR;
        }
        if (!Int32.TryParse(fsleep, out sleep)) {
            Console.WriteLine("Cannot parse sleep from {0}", fsleep);
            return ERROR_SLEEP_PARSE_ERR;
        }

        startTime2 = DateTime.Now;
        while (loops < time) {
            using (StreamWriter outputFile = new StreamWriter(fpath, true)) {
                startTime = DateTime.Now;
                for (int i = 0; i < random.Next(1024, 2048); i++) {
                    outputFile.WriteLine(RandomString());
                }
                endTime = DateTime.Now;
                Console.WriteLine("{1} Elapsed {0}ms", (endTime - startTime).TotalMilliseconds, loops);
            }
            loops++;
            Thread.Sleep(sleep);
        }
        endTime2 = DateTime.Now;

        Console.WriteLine("Elapsed {0}ms", (endTime2 - startTime2).TotalMilliseconds);

        return RETURN_SUCCESS;
    }

    static string RandomString(int length = 255) {
        string str = "";
        for (int i = 0; i < length; i++) {
            str += (char)random.Next(32, 126);
        }
        return str;
    }
}
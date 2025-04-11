using UnityEngine;
using System;
using System.IO;
using System.Collections.Generic;

public class Survey_Choice : MonoBehaviour
{
    private string filePath;
    private int[] answers = new int[3]; // Fixed-size array for 3 questions
    private int index = 0;
    void Start()
    {
        filePath = Path.Combine(Application.persistentDataPath, "survey.txt");
        //LoadExistingEntries();

        for (int i = 0; i < answers.Length; i++)
        {
            answers[i] = -1;
        }
    }

    // Button click handlers
    public void oneClicked() => SaveChoice(1);
    public void twoClicked() => SaveChoice(2);
    public void threeClicked() => SaveChoice(3);
    public void fourClicked() => SaveChoice(4);
    public void fiveClicked() => SaveChoice(5);

    public void BackButtonClicked()
    {
        index--;
        Debug.Log($"Index:{index}");
        DebugSurveyState();

    }

    public void NextButtonClicked()
    {
        index++;
        Debug.Log($"Index:{index}");
        DebugSurveyState();
    }

    public void EndButtonClicked()
    {
        SaveAllEntries();
    }

    private void SaveChoice(int selectedChoice)
    {
        answers[index] = selectedChoice;
        Debug.Log($"You chose:{answers[index]}");
    }
    /*
    private void LoadExistingEntries()
    {
        if (File.Exists(filePath))
        {
            string[] lines = File.ReadAllLines(filePath);
            foreach (string line in lines)
            {
                if (int.TryParse(line, out int value))
                {
                    entries.Add(value);
                }
            }
        }
    }
    */
    private void SaveAllEntries()
    {
        bool append = File.Exists(filePath);

        try
        {
            using (StreamWriter sw = new StreamWriter(filePath, append))
            {
                sw.WriteLine($"Survey Results - {DateTime.Now:yyyy-MM-dd HH:mm}");
                sw.WriteLine("------------------");

                for (int i = 0; i < answers.Length; i++)
                {
                    sw.WriteLine($"Q{i + 1}: {answers[i]}");
                }
                sw.WriteLine("------------------");
            }

            Debug.Log($"Survey saved to: {filePath}");
        }
        catch (Exception e)
        {
            Debug.LogError($"Save failed: {e.Message}");
        }
    }

    private void DebugSurveyState()
    {
        string state = $"CURRENT QUESTION: {index + 1}\n";
        state += "ANSWERS:\n";

        for (int i = 0; i < answers.Length; i++)
        {
            string status = (i == index) ? "> " : "  ";
            status += $"Q{i + 1}: {(answers[i] == -1 ? "Unanswered" : answers[i].ToString())}";
            state += status + "\n";
        }

        Debug.Log(state);
    }
}
/*
MIT License

Copyright (c) 2025, Nuno Datia, Matilde Pato, ISEL

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
package isel.sisinf.ui;

import java.util.Scanner;
import java.util.HashMap;

/**
 * 
 * Didactic material to support 
 * to the curricular unit of 
 * Introduction to Information Systems 
 *
 * The examples may not be complete and/or totally correct.
 * They are made available for teaching and learning purposes and 
 * any inaccuracies are the subject of debate.
 */

interface DbWorker
{
    void doWork();
}
class UI
{
    private enum Option
    {
        // DO NOT CHANGE ANYTHING!
        Unknown,
        Exit,
        createCostumer,
        listCostumer,
        listDocks,
        startTrip,
        parkScooter,
        about
    }
    private static UI __instance = null;
  
    private HashMap<Option,DbWorker> __dbMethods;

    private UI()
    {
        // DO NOT CHANGE ANYTHING!
        __dbMethods = new HashMap<Option,DbWorker>();
        __dbMethods.put(Option.createCostumer, () -> UI.this.createCostumer());
        __dbMethods.put(Option.listCostumer, () -> UI.this.listCostumer()); 
        __dbMethods.put(Option.listDocks, () -> UI.this.listDocks());
        __dbMethods.put(Option.startTrip, new DbWorker() {public void doWork() {UI.this.startTrip();}});
        __dbMethods.put(Option.parkScooter, new DbWorker() {public void doWork() {UI.this.parkScooter();}});
        __dbMethods.put(Option.about, new DbWorker() {public void doWork() {UI.this.about();}});
    }

    public static UI getInstance()
    {
        // DO NOT CHANGE ANYTHING!
        if(__instance == null)
        {
            __instance = new UI();
        }
        return __instance;
    }

    private Option DisplayMenu()
    {
        Option option = Option.Unknown;
        Scanner s = new Scanner(System.in); //Scanner closes System.in if you call close(). Don't do it
        try
        {
            // DO NOT CHANGE ANYTHING!
            System.out.println("CITES Manadgement DEMO");
            System.out.println();
            System.out.println("1. Exit");
            System.out.println("2. Create Costumer");
            System.out.println("3. List Existing Costumer");
            System.out.println("4. List Docks");
            System.out.println("5. Start Trip");
            System.out.println("6. Park Scooter");
            System.out.println("8. About");
            System.out.print(">");
            int result = s.nextInt();
            option = Option.values()[result];
        }
        catch(RuntimeException ex)
        {
            //nothing to do.
        }
        
        return option;

    }
    private static void clearConsole() throws Exception
    {
        // DO NOT CHANGE ANYTHING!
        for (int y = 0; y < 25; y++) //console is 80 columns and 25 lines
            System.out.println("\n");
    }

    public void Run() throws Exception
    {
        // DO NOT CHANGE ANYTHING!
        Option userInput;
        do
        {
            clearConsole();
            userInput = DisplayMenu();
            clearConsole();
            try
            {
                __dbMethods.get(userInput).doWork();
                System.in.read();
            }
            catch(NullPointerException ex)
            {
                //Nothing to do. The option was not a valid one. Read another.
            }

        }while(userInput!=Option.Exit);
    }

    /**
    To implement from this point forward. 
    -------------------------------------------------------------------------------------     
        IMPORTANT:
    --- DO NOT MESS WITH THE CODE ABOVE. YOU JUST HAVE TO IMPLEMENT THE METHODS BELOW ---
    --- Other Methods and properties can be added to support implementation. 
    ---- Do that also below                                                         -----
    -------------------------------------------------------------------------------------
    
    */

    private static final int TAB_SIZE = 24;

    private void createCostumer() {
   
        Scanner s = new Scanner(System.in);
        System.out.print("Nome: ");
        String name = s.nextLine();
        System.out.print("Email: ");
        String email = s.nextLine();
        System.out.print("NIF: ");
        String nif = s.nextLine();
        System.out.print("Tipo de Passe (ex: BASIC, PREMIUM): ");
        String passType = s.nextLine();
        System.out.print("Crédito inicial: ");
        double credit = Double.parseDouble(s.nextLine());

        try {
            isel.sisinf.jpa.Dal.createCostumer(name, email, nif, passType, credit);
            System.out.println("Cliente criado com sucesso.");
        } catch (Exception ex) {
            System.out.println("Erro: " + ex.getMessage());
        }
    }

        System.out.println("createCostumer()");
    }
  
    private void listCostumer() { 

        Scanner s = new Scanner(System.in);
        System.out.print("Introduza NIF: ");
        String nif = s.nextLine();

        try {
            var rider = isel.sisinf.jpa.Dal.getCostumerByNif(nif);
            if (rider == null) {
            System.out.println("Cliente não encontrado.");
            } else {
                System.out.printf("%-" + TAB_SIZE + "s%s\n", "Nome:", rider.getName());
                System.out.printf("%-" + TAB_SIZE + "s%s\n", "Email:", rider.getEmail());
                System.out.printf("%-" + TAB_SIZE + "s%s\n", "Tipo de Passe:", rider.getTypeOfCard());
                System.out.printf("%-" + TAB_SIZE + "s%.2f€\n", "Crédito:", rider.getCredit());
            }
        } catch (Exception e) {
            System.out.println("Erro ao buscar cliente: " + e.getMessage());
        }
        System.out.println("listCostumer()");
    }


    private void listDocks() {
        
        Scanner s = new Scanner(System.in);
        System.out.print("ID da Estação: ");
        int stationId = Integer.parseInt(s.nextLine());

        try {
            double ocupacao = isel.sisinf.jpa.Dal.getDockOccupancy(stationId);
            System.out.printf("Ocupação da estação: %.2f%%\n", ocupacao * 100);

            var docas = isel.sisinf.jpa.Dal.getDocksByStation(stationId);
            for (var d : docas) {
                System.out.printf("Doca: %d | Estado: %s\n", d.getNumber(), d.getState());
            }
        } catch (Exception e) {
            System.out.println("Erro: " + e.getMessage());
        }
        System.out.println("listDocks()");
    }

    private void startTrip() {

        Scanner s = new Scanner(System.in);
        System.out.print("ID da doca: ");
        int dockId = Integer.parseInt(s.nextLine());

        System.out.print("ID do cliente: ");
        int clientId = Integer.parseInt(s.nextLine());

        try {
            isel.sisinf.jpa.Dal.startTrip(dockId, clientId);
            System.out.println("Viagem iniciada com sucesso.");
        } catch (Exception e) {
            System.out.println("Erro ao iniciar viagem: " + e.getMessage());
        }
        System.out.println("startTrip()");
    }
    

    private void parkScooter() {
        
        Scanner s = new Scanner(System.in);
        System.out.print("ID da trotinete: ");
        int scooterId = Integer.parseInt(s.nextLine());
        System.out.print("Número da doca: ");
        int dockNumber = Integer.parseInt(s.nextLine());

        try {
            isel.sisinf.jpa.Dal.parkScooter(scooterId, dockNumber);
            System.out.println("Trotinete estacionada com sucesso.");
        } catch (OptimisticLockException ole) {
            System.out.println("Erro de concorrência: outra operação alterou a doca.");
        } catch (Exception e) {
            System.out.println("Erro: " + e.getMessage());
        }
        System.out.println("parkScooter()");
    }

    private void about()
    {
        System.out.println("Grupo: G18T42D");
        System.out.println("Autores:");
        System.out.println("- Afonso Abranja");
        System.out.println("- Cecília Marino");
        System.out.println("- Simão Silva");
        
        System.out.println("DAL version:"+ isel.sisinf.jpa.Dal.version());
        System.out.println("Core version:"+ isel.sisinf.model.Core.version());
        
    }
}

public class App{
    public static void main(String[] args) throws Exception{
        UI.getInstance().Run();
    }
}

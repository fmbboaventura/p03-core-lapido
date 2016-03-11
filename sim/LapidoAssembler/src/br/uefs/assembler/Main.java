package br.uefs.assembler;

import java.io.*;
import java.util.HashMap;

public class Main {

    public static final String OPCODE_FILE = "data/opcode.txt";
    public static final String FUNCT_FILE = "data/funct.txt";
    private static HashMap<String, Integer> labelMap, opcodeMap, functMap;
    private static File input, dOut, pOut;
    private static int currentLine = 0;
    private static int codeLineCnt = 0;

    public static void main(String[] args) {
        System.out.println("-----------------------------------");
        System.out.println("LAPI DOpaCA LAMBA Assembler ver 2.0");
        System.out.println("-----------------------------------");

        opcodeMap = new HashMap<>();
        functMap = new HashMap<>();
        labelMap = new HashMap<>();

        if (args.length == 0) {
            System.out.println("Por favor, execute o Assembler da seguinte forma: ");
            System.out.println("\t run_assembler <arquivo assembly> <opcoes>\n");
            System.out.println("Onde as posiveis opcoes incluem: ");
            System.out.println(" -p <arquivo de saida> \tEspecifica o arquivo de " +
                    "saida que recebera o segmento de codigo em linguagem de maquina\n");
            System.out.println(" -d <arquivo de saida> \tEspecifica o arquivo de " +
                    "saida que recebera o segmento de dados em linguagem de maquina");
            System.exit(-1);
        }

        String input = args[0];

        Main.input = new File(input);

        String dsegOut = "dseg_" + Main.input.getName() + ".txt";
        String psegOut = "pseg_" + Main.input.getName() + ".txt";

        if (args.length > 2) {
            for (int i = 1; i < args.length; i++) {
                if (args[i].equals("-p")) {
                    psegOut = args[i + 1];
                    i++;
                } else if (args[i].equals("-d")) {
                    dsegOut = args[i + 1];
                    i++;
                }
            }
        }

        dOut = new File(dsegOut);
        pOut = new File(psegOut);

        System.out.println("\nArquivo assembly (entrada): " + Main.input.getName());
        System.out.println("Arquivo em linguagem de maquina (instrucao): " + pOut.getName());
        System.out.println("Arquivo em linguagem de maquina (dados): " + dOut.getName());

        try {
            loadInstructionData();
            indexLabels();
        } catch (IOException e) {
            e.printStackTrace();
        }

//        try {
//            BufferedWriter writer = new BufferedWriter(new FileWriter(dOut));
//            writer.write(String.format("%08X", 15));
//            writer.close();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
    }

    /**
     * Inicializa o HashMap de labels
     *
     * @throws IOException
     */
    private static void indexLabels() throws IOException {
        BufferedReader sourceBr = new BufferedReader(new FileReader(input));
        String line, label;
        String aux[];

        boolean labelFound = false;
        boolean incrementLineCount = true;

        System.out.println("Primeira leitura: indexando labels");

        while ((line = sourceBr.readLine()) != null) {
            currentLine++;
            line = line.trim();
            aux = line.split("\\s+");

            for (String s : aux) {
                if (s.contains(";")) {
                    break;
                } else if (s.length() > 0) {
                    if (s.contains(":")) {
                        incrementLineCount = false;
                        if (labelFound) reportSyntaxError(currentLine, "Definicao de multiplas " +
                                "labels em uma linha");

                        labelFound = true;
                        label = s.split(":")[0];

                        labelMap.put(label, codeLineCnt);
                        System.out.println("Label encontrada:");
                        System.out.println(label + " " + codeLineCnt + "\n");
                    } else if (s.equals(".dseg")) {
                        System.out.println("Segmento de dados encontrado");
                        codeLineCnt = 0;
                        break;
                    } else if (s.equals(".pseg") || s.equals(".module")) {
                        break;
                    }

                    if (incrementLineCount) {
                        codeLineCnt++;
                        break;
                    }
                }
            }
            labelFound = false;
            incrementLineCount = true;
        }
    }

    /**
     * Carrega os opcodes e funct.
     *
     * @throws IOException
     */
    private static void loadInstructionData() throws IOException {
        BufferedReader opcodeIn = new BufferedReader(new FileReader(new File(OPCODE_FILE)));
        BufferedReader functIn = new BufferedReader(new FileReader(new File(FUNCT_FILE)));

        String line;
        String[] aux;

        System.out.println("\nCarregando dados das instrucoes...");

        while ((line = opcodeIn.readLine()) != null) {
            aux = line.split("\\s+");
            opcodeMap.put(aux[0], Integer.parseInt(aux[1], 16));
        }

        while ((line = functIn.readLine()) != null) {
            aux = line.split("\\s+");
            functMap.put(aux[0], Integer.parseInt(aux[1], 16));
        }

        System.out.println("Concluido!\n");

//        for (String s :
//                opcodeMap.keySet()) {
//            System.out.printf(s + " %08X\n", opcodeMap.get(s));
//        }
//
//        for (String s :
//                functMap.keySet()) {
//            System.out.printf(s + " %08X\n", functMap.get(s));
//        }

        opcodeIn.close();
        functIn.close();
    }

    private static void reportSyntaxError(int currentLine, String s) {
        System.out.println("Erro na linha " + currentLine + ": " + s);
        System.exit(-1);
    }
}

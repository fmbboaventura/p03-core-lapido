package br.uefs.assembler;

import java.io.*;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;

public class Main {

    public static final String OPCODE_FILE = "data/opcode.txt";
    public static final String FUNCT_FILE = "data/funct.txt";
    public static final String FLAG_FILE = "data/flag.txt";

    private static HashMap<String, Integer> labelMap, opcodeMap, functMap, flagMap;
    private static File input, dOut, pOut;
    private static int currentLine = 0;
    private static int codeLineCnt = 0;

    public static void main(String[] args) {
        float beginTime = System.nanoTime();
        System.out.println("-----------------------------------");
        System.out.println("LAPI DOpaCA LAMBA Assembler ver 2.0");
        System.out.println("-----------------------------------");

        opcodeMap = new HashMap<>();
        functMap = new HashMap<>();
        labelMap = new HashMap<>();
        flagMap = new HashMap<>();

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

        dOut = new File("assembled_files/" + dsegOut);
        pOut = new File("assembled_files/" + psegOut);

        System.out.println("\nArquivo assembly (entrada): " + Main.input.getName());
        System.out.println("Arquivo em linguagem de maquina (instrucao): " + pOut.getName());
        System.out.println("Arquivo em linguagem de maquina (dados): " + dOut.getName());

        try {
            loadInstructionData();
            indexLabels();
            assembleFile();
        } catch (IOException e) {
            e.printStackTrace();
        }

        System.out.println("\n-----------------------------------");
        System.out.printf("Traducao Conluida em %fs\n", (System.nanoTime() - beginTime)/1000000000.0f);
        System.out.println("-----------------------------------");
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
        sourceBr.close();
    }

    private static void assembleFile() throws IOException {
        BufferedReader sourceBr = new BufferedReader(new FileReader(input));
        BufferedWriter progBw = new BufferedWriter(new FileWriter(pOut));
        BufferedWriter dataBw = new BufferedWriter(new FileWriter(dOut));

        String line;
        String aux[];

        currentLine = 0;
        codeLineCnt = 0;

        int sftOpcode = 26;
        int sftRs = 21;//16;
        int sftRt = 16;//11;
        int sftRd = 11;//21;

        boolean incrementLineCount = true;

        System.out.println("Segunda Leitura: Traducao");

        while ((line = sourceBr.readLine()) != null) {
            currentLine++;

            //line = line.trim().toUpperCase();
            aux = parseLine(line);//line.split("\\s+");

            for (int i =0; i < aux.length; i++) {
                String s = aux[i];
                if (s.length() > 0) {
                    if(s.contains(";")) {
                        break;
                    } else if (s.equals(".PSEG") || s.equals(".MODULE") || s.equals(".END")){
                        break;
                    } else if (s.equals(".DSEG")){
                        System.out.println("Lendo segmento de dados...");
                        break;
                    } else if (s.equals(".WORD")) {
                        int word = Integer.parseInt(aux[1]);
                        System.out.println("Escrevendo constante: " + word );
                        writeAssembled(dataBw, word);
                        break;
                    }else if (s.contains(":")){
                        continue;
                    }
                    else {

                        String cond = null; // Condição do jt/jf
                        if(s.contains(".")){
                            String[] split = s.split(".");
                            if (split.length > 2) reportSyntaxError(currentLine, "Problema na traducao da instrucao");
                            s = split[0];
                            cond = split[1];
                        }
                        int opcode = opcodeMap.get(s);
                        int instruction = opcode << sftOpcode;
                        char type = identifyType(opcode);

                        switch (type) {
                            case 'r':
                                int funct = functMap.get(s);

                                int rd = Integer.parseInt(aux[i + 1].substring(1));

                                if (s.equals("ZEROS")){
                                    instruction = instruction | (rd << sftRd);
                                    instruction = instruction | (rd << sftRs);
                                    instruction = instruction | (rd << sftRt);
                                } else if(s.equals("JR")){
                                    instruction = instruction | (rd << sftRs);
                                } else if(s.equals("RET")){
                                    instruction = instruction | (0x0F << sftRs);
                                } else{
                                    instruction = instruction | (rd << sftRd);

                                    int rs = Integer.parseInt(aux[i + 2].substring(1));
                                    instruction = instruction | (rs << sftRs);

                                    if (!s.equals("NOT") && !s.equals("PASSNOTA") &&
                                            !s.equals("LSL") && !s.equals("LSR") &&
                                            !s.equals("ASL") && !s.equals("ASR")) {
                                        int rt = Integer.parseInt(aux[i + 3].substring(1));
                                        instruction = instruction | (rt << sftRt);
                                    }
                                }

                                instruction = instruction | funct;
                                System.out.println("Escrevendo Instrucao: " + s);
                                writeAssembled(progBw, instruction);

                                break;
                            case 'i':
                                //int rs = Integer.parseInt(aux[i + 1].substring(1))
                                if(s.equals("JT") || s.equals("JF")){

                                    int flagCode = flagMap.get(cond);
                                    instruction = instruction | (flagCode << sftRs);
                                    instruction = instruction | computeBranchOffset(aux[i + 1], codeLineCnt);

                                } else if (s.equals("BEQ") || s.equals("BNE")){
                                    int rs = Integer.parseInt(aux[i + 1].substring(1));
                                    int rt = Integer.parseInt(aux[i + 2].substring(1));

                                    instruction = instruction | (rs << sftRs);
                                    instruction = instruction | (rt << sftRt);
                                    instruction = instruction | computeBranchOffset(aux[i + 3], codeLineCnt);
                                } else if (s.equals("LCL") || s.equals("LCH")) {
                                    int rt = Integer.parseInt(aux[i + 1].substring(1));
                                    instruction = instruction | (rt << sftRt);

                                    int imm = 0;
                                    if(aux[i + 2].equals("HIGHBYTE")){
                                        imm = labelMap.containsKey(aux[i + 3]) ?
                                                labelMap.get(aux[i + 3]) :
                                                Integer.parseInt(aux[i + 3]);
                                        imm = imm >>> 16; //shift lógico
                                    } else if (aux[i + 2].equals("LOWBYTE")) {
                                        imm = labelMap.containsKey(aux[i + 3]) ?
                                                labelMap.get(aux[i + 3]) :
                                                Integer.parseInt(aux[i + 3]);
                                        imm = imm & 0xFFFF;
                                    } else {
                                        imm = Integer.parseInt(aux[i + 2]);
                                    }
                                    instruction = instruction | imm;
                                } else if(s.equals("LOAD")){
                                    int rs = Integer.parseInt(aux[i + 2].substring(1));
                                    int rt = Integer.parseInt(aux[i + 1].substring(1));

                                    instruction = instruction | (rs << sftRs);
                                    instruction = instruction | (rt << sftRt);
                                } else if(s.equals("STORE")){
                                    int rs = Integer.parseInt(aux[i + 1].substring(1));
                                    int rt = Integer.parseInt(aux[i + 2].substring(1));

                                    instruction = instruction | (rs << sftRs);
                                    instruction = instruction | (rt << sftRt);
                                } else if(s.equals("LOADLIT")) {
                                    int rt = Integer.parseInt(aux[i + 1].substring(1));
                                    int imm = Integer.parseInt(aux[i + 2]);
                                    imm =  0xFFFF & imm;

                                    instruction = instruction | (rt << sftRt);
                                    instruction = instruction | imm;
                                } else if(s.equals("JAL")) {
                                    int rs = Integer.parseInt(aux[i + 1].substring(1));
                                    instruction = instruction | (rs << sftRs);
                                } else if (s.equals("PASSA")) { // addi com zero
                                    int rs = Integer.parseInt(aux[i + 2].substring(1));
                                    int rt = Integer.parseInt(aux[i + 1].substring(1));
                                    instruction = instruction | (rs << sftRs);
                                    instruction = instruction | (rt << sftRt);
                                } else if (s.equals("INCA")) { // addi com 1
                                    int rs = Integer.parseInt(aux[i + 2].substring(1));
                                    int rt = Integer.parseInt(aux[i + 1].substring(1));
                                    instruction = instruction | (rs << sftRs);
                                    instruction = instruction | (rt << sftRt);
                                    instruction = instruction | 1;
                                } else if (s.equals("DECA")) { // addi com -1
                                    int rs = Integer.parseInt(aux[i + 2].substring(1));
                                    int rt = Integer.parseInt(aux[i + 1].substring(1));
                                    instruction = instruction | (rs << sftRs);
                                    instruction = instruction | (rt << sftRt);
                                    instruction = instruction | (0xFFFF & (-1));
                                } else {
                                    int rs = Integer.parseInt(aux[i + 2].substring(1));
                                    int rt = Integer.parseInt(aux[i + 1].substring(1));
                                    int imm = Integer.parseInt(aux[i + 3]);

                                    instruction = instruction | (rs << sftRs);
                                    instruction = instruction | (rt << sftRt);
                                    instruction = instruction | (0xFFFF & (imm));
                                }

                                System.out.println("Escrevendo Instrucao: " + s);
                                writeAssembled(progBw, instruction);
                                break;
                            case 'j':
                                int addr = labelMap.get(aux[i + 1]);
                                instruction = instruction | addr;
                                System.out.println("Escrevendo Instrucao: " + s);
                                writeAssembled(progBw, instruction);
                                break;
                        }
                        codeLineCnt++;
                        break;
                    }
                }
            }
        }

        sourceBr.close();
        progBw.close();
        dataBw.close();
    }

    /**
     * Carrega os opcodes e funct.
     *
     * @throws IOException
     */
    private static void loadInstructionData() throws IOException {
        BufferedReader opcodeIn = new BufferedReader(new FileReader(new File(OPCODE_FILE)));
        BufferedReader functIn = new BufferedReader(new FileReader(new File(FUNCT_FILE)));
        BufferedReader flagIn = new BufferedReader(new FileReader(new File(FLAG_FILE)));

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

        while ((line = flagIn.readLine()) != null) {
            aux = line.split("\\s+");
            flagMap.put(aux[0], Integer.parseInt(aux[1]));
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

//        for (String s :
//                flagMap.keySet()) {
//            System.out.printf(s + " %08X\n", flagMap.get(s));
//        }

        opcodeIn.close();
        functIn.close();
        flagIn.close();
    }

    private static String[] parseLine(String line){
        LinkedList<String> parsedLineList = new LinkedList<>();
        String[] firstSplit, aux;

        line = line.trim().toUpperCase();
        
        firstSplit = line.split("\\s+"); // Remove 1 ou mais espaços em branco

        for (String s1 : firstSplit) { // Percorre para remover eventuais ','
            if(s1.length() > 0){
                if(s1.endsWith(";") && s1.length() > 1)
                    s1 = s1.split(";")[0];
                if(s1.contains(",")){
                    aux = s1.split(",");

                    for (String s2 : aux) {
                        if(s2.length() > 0){
                            parsedLineList.add(s2);
                        }
                    }
                } else {
                    parsedLineList.add(s1);
                }
            }
        }


        return Arrays.copyOf(parsedLineList.toArray(), parsedLineList.size(), String[].class);
    }

    private static void writeAssembled(BufferedWriter writer, int data) throws IOException {
        writeAssembled(writer, data, "%08X");
    }

    private static void writeAssembled(BufferedWriter writer, int data, String format) throws IOException {
        writer.write(String.format(format, data));
        writer.newLine();
        //        try {
        //            BufferedWriter writer = new BufferedWriter(new FileWriter(dOut));
        //            writer.write(String.format("%08X", 15));
        //            writer.close();
        //        } catch (IOException e) {
        //            e.printStackTrace();
        //        }
    }

    private static char identifyType(int opcode)
    {
        char result;

        if (opcode == 0x00)
        {
            result = 'r';
        }
        else if (opcode == 0x01 || // lcl
                opcode == 0x03 || // jal
                opcode == 0x04 || // beq
                opcode == 0x05 || // bne
                opcode == 0x06 || // loadlit
                opcode == 0x07 || // lch
                opcode == 0x08 || // addi
                opcode == 0x09 || // jt
                opcode == 0x0a || // slti
                opcode == 0x0c || // andi
                opcode == 0x0d || // ori
                opcode == 0x10 || // jf
                opcode == 0x23 || // load
                opcode == 0x2b)   // store
        {
            result = 'i';
        }
        else if (opcode == 0x02) // jump
        {
            result = 'j';
        }
        else
        {
            reportSyntaxError(currentLine, String.format("ERRO!! OPCODE 0x%02X DESCONHECIDO!!", opcode));
            result = 'e';
        }

        return result;
    }

    private static int computeBranchOffset(String label, int codeLineCnt){
        int labelAddr = labelMap.get(label);
        // instrução alvo - (instrução atual +1)
        return (labelAddr - (codeLineCnt + 1)) & 0x0000ffff;
    }

    private static void reportSyntaxError(int currentLine, String s) {
        System.out.println("Erro na linha " + currentLine + ": " + s);
        System.exit(-1);
    }
}

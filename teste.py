import pyshark
from openpyxl import Workbook
workbook = Workbook()
sheet = workbook.active
sheet.title = 'Packet Capture'

pcap_file = "C:/Users/warma/Downloads/tsg 2019/arquivos/scada_new_capture.pcap40"
xlsx_file = "C:/Users/warma/Downloads/tsg 2019/arquivos/scada_cap.xlsx"

capture = pyshark.FileCapture(pcap_file)

# Escrever o cabeçalho
sheet.append(['Timestamp', 'Source IP', 'Destination IP', 'Protocol', 'Length', 'Info'])

# Processar e escrever os dados dos pacotes no arquivo Excel
for packet in capture:
    try:
        timestamp = packet.sniff_time
        src_ip = packet.ip.src
        dst_ip = packet.ip.dst
        protocol = packet.highest_layer
        length = packet.length
        info = packet.info if hasattr(packet, 'info') else 'N/A'

        sheet.append([timestamp, src_ip, dst_ip, protocol, length, info])
    except AttributeError:
        continue

# Salvar o arquivo Excel
workbook.save(xlsx_file)

print(f'Dados extraídos e salvos em {xlsx_file}')
echo -n "0000:00:02.0" | tee /sys/bus/pci/drivers/ohci_hcd/unbind
echo -n "0000:00:02.0" | tee /sys/bus/pci/drivers/ohci_hcd/bind

echo -n "0000:00:02.1" | tee /sys/bus/pci/drivers/ehci-pci/unbind
echo -n "0000:00:02.1" | tee /sys/bus/pci/drivers/ehci-pci/bind


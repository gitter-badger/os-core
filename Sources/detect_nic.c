#include <libudev.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <locale.h>
#include <unistd.h>

int main (void)
{
	struct udev *udev;
	struct udev_enumerate *enumerate;
	struct udev_list_entry *devices, *dev_list_entry;
	struct udev_device *dev;

	// Initialize udev context
	udev = udev_new();
	if (!udev) {
		printf("Can't create udev\n");
		exit(1);
	}
	// Create an enumeration object, filter it to net subsystem
	enumerate = udev_enumerate_new(udev);
	udev_enumerate_add_match_subsystem(enumerate, "pci");
	udev_enumerate_scan_devices(enumerate);
	devices = udev_enumerate_get_list_entry(enumerate);
	// Iterate over all devices
	udev_list_entry_foreach(dev_list_entry, devices) {
		const char *path;

		path = udev_list_entry_get_name(dev_list_entry);
		dev = udev_device_new_from_syspath(udev, path);
		char *contains_id = strstr(udev_device_get_sysattr_value(dev, "class"), "020000");
		if(!contains_id){
			continue;
			}

		printf("%s ",
		        udev_device_get_sysattr_value(dev, "modalias"));
	}
	// clean it up
	udev_enumerate_unref(enumerate);

	udev_unref(udev);

	return 0;
}

#include <gio/gio.h>

#if defined (__ELF__) && ( __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 6))
# define SECTION __attribute__ ((section (".gresource.kvartplata"), aligned (8)))
#else
# define SECTION
#endif

static const SECTION union { const guint8 data[2559]; const double alignment; void * const ptr;}  kvartplata_resource_data = { {
  0x47, 0x56, 0x61, 0x72, 0x69, 0x61, 0x6e, 0x74, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x18, 0x00, 0x00, 0x00, 0xac, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x28, 0x05, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 
  0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 
  0x03, 0x00, 0x00, 0x00, 0xd4, 0xb5, 0x02, 0x00, 
  0xff, 0xff, 0xff, 0xff, 0xac, 0x00, 0x00, 0x00, 
  0x01, 0x00, 0x4c, 0x00, 0xb0, 0x00, 0x00, 0x00, 
  0xb8, 0x00, 0x00, 0x00, 0xef, 0xe5, 0x24, 0xcb, 
  0x02, 0x00, 0x00, 0x00, 0xb8, 0x00, 0x00, 0x00, 
  0x08, 0x00, 0x76, 0x00, 0xc0, 0x00, 0x00, 0x00, 
  0xcf, 0x01, 0x00, 0x00, 0x9d, 0x37, 0xca, 0x7c, 
  0x00, 0x00, 0x00, 0x00, 0xcf, 0x01, 0x00, 0x00, 
  0x05, 0x00, 0x4c, 0x00, 0xd4, 0x01, 0x00, 0x00, 
  0xd8, 0x01, 0x00, 0x00, 0xc1, 0xd4, 0x78, 0x7c, 
  0x00, 0x00, 0x00, 0x00, 0xd8, 0x01, 0x00, 0x00, 
  0x03, 0x00, 0x4c, 0x00, 0xdc, 0x01, 0x00, 0x00, 
  0xe0, 0x01, 0x00, 0x00, 0x37, 0xed, 0xd0, 0xa4, 
  0x03, 0x00, 0x00, 0x00, 0xe0, 0x01, 0x00, 0x00, 
  0x0e, 0x00, 0x76, 0x00, 0xf0, 0x01, 0x00, 0x00, 
  0xff, 0x09, 0x00, 0x00, 0x2f, 0x00, 0x00, 0x00, 
  0x02, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 
  0x69, 0x6e, 0x69, 0x74, 0x2e, 0x73, 0x71, 0x6c, 
  0xaa, 0x03, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 
  0x78, 0xda, 0xc5, 0x93, 0xcb, 0x0e, 0x82, 0x30, 
  0x10, 0x45, 0xd7, 0xf2, 0x15, 0xb3, 0xd4, 0x84, 
  0x3f, 0x70, 0x85, 0x64, 0x34, 0x8d, 0x58, 0x4d, 
  0x1d, 0x13, 0xdd, 0xb5, 0x62, 0x13, 0x48, 0xe4, 
  0x11, 0xac, 0x46, 0xff, 0xde, 0x07, 0x08, 0xa8, 
  0x89, 0x80, 0x1b, 0x67, 0x7f, 0x9a, 0x7b, 0x6e, 
  0x67, 0x5c, 0x81, 0x0e, 0x21, 0x90, 0x33, 0xf2, 
  0x10, 0xd8, 0x18, 0xf8, 0x9c, 0x00, 0xd7, 0x6c, 
  0x49, 0x4b, 0x90, 0xca, 0xf7, 0x93, 0x63, 0x6c, 
  0x24, 0xf4, 0xad, 0x9e, 0x0c, 0x77, 0x12, 0x9e, 
  0xc3, 0x38, 0xe1, 0x04, 0x05, 0xc0, 0x42, 0xb0, 
  0x99, 0x23, 0x36, 0x30, 0xc5, 0x0d, 0x38, 0x2b, 
  0x9a, 0x33, 0xee, 0x0a, 0x9c, 0x21, 0x27, 0x78, 
  0x3c, 0xc4, 0x57, 0x9e, 0x67, 0xdf, 0xd8, 0xf8, 
  0x18, 0x6d, 0x75, 0x96, 0xf3, 0x84, 0x6b, 0x82, 
  0x86, 0xa9, 0xb3, 0x2a, 0x55, 0x99, 0x89, 0xf4, 
  0x3d, 0x46, 0x27, 0xd6, 0x1a, 0x0c, 0x2d, 0xcb, 
  0xfd, 0x62, 0x97, 0xea, 0x24, 0xdd, 0xeb, 0x0f, 
  0xb9, 0xd2, 0xad, 0xb5, 0x9c, 0x8a, 0x74, 0x41, 
  0xb7, 0xc9, 0xf7, 0xc2, 0x6e, 0xc3, 0xcc, 0x04, 
  0x3b, 0x75, 0x91, 0x1d, 0xd9, 0x46, 0xb9, 0x83, 
  0xce, 0x4e, 0xa1, 0xff, 0x47, 0xbb, 0xc6, 0x84, 
  0x46, 0x9d, 0xf5, 0x21, 0xcf, 0x17, 0x25, 0xb1, 
  0x09, 0xe4, 0x5b, 0xbe, 0x96, 0x0d, 0x5e, 0xb4, 
  0x2a, 0x16, 0xab, 0x3b, 0x5b, 0xee, 0xf7, 0x0f, 
  0x6c, 0x59, 0x70, 0x77, 0xb6, 0xde, 0x7c, 0xbf, 
  0x90, 0xb7, 0x21, 0x37, 0xb1, 0xab, 0xab, 0xb3, 
  0xab, 0x5f, 0x1c, 0xdc, 0xdb, 0xbc, 0x02, 0x5f, 
  0xef, 0xd5, 0xa7, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x28, 0x75, 0x75, 0x61, 0x79, 0x29, 0x64, 
  0x61, 0x74, 0x61, 0x2f, 0x01, 0x00, 0x00, 0x00, 
  0x75, 0x69, 0x2f, 0x00, 0x04, 0x00, 0x00, 0x00, 
  0x6d, 0x61, 0x69, 0x6e, 0x2d, 0x77, 0x69, 0x6e, 
  0x64, 0x6f, 0x77, 0x2e, 0x75, 0x69, 0x00, 0x00, 
  0x51, 0x26, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 
  0x78, 0xda, 0xd5, 0x5a, 0xcd, 0x6e, 0xe3, 0x36, 
  0x10, 0xbe, 0xef, 0x53, 0xa8, 0xec, 0xb1, 0x50, 
  0x1c, 0xdb, 0xd9, 0x22, 0x07, 0x5b, 0x8b, 0x24, 
  0xc0, 0x06, 0xc5, 0x76, 0xbb, 0x8b, 0x24, 0x6d, 
  0x8f, 0x02, 0x2d, 0x8d, 0x2d, 0x36, 0x34, 0xa9, 
  0x92, 0x94, 0x7f, 0x7a, 0xea, 0x03, 0x14, 0xe8, 
  0xab, 0x14, 0xbd, 0xf7, 0x1d, 0x92, 0x37, 0xea, 
  0x50, 0x92, 0xe5, 0x7f, 0xcb, 0xff, 0x76, 0x2e, 
  0x86, 0x44, 0x0d, 0xa9, 0xe1, 0x37, 0x33, 0xdf, 
  0x0c, 0x47, 0x6e, 0x7c, 0x18, 0x74, 0xb9, 0xd3, 
  0x03, 0xa5, 0x99, 0x14, 0x4d, 0x52, 0xbd, 0xb8, 
  0x24, 0x0e, 0x88, 0x40, 0x86, 0x4c, 0x74, 0x9a, 
  0xe4, 0xe7, 0xa7, 0x8f, 0xee, 0x35, 0xf9, 0xe0, 
  0xbd, 0x6b, 0x7c, 0xe3, 0xba, 0xce, 0x3d, 0x08, 
  0x50, 0xd4, 0x40, 0xe8, 0xf4, 0x99, 0x89, 0x9c, 
  0x0e, 0xa7, 0x21, 0x38, 0xf5, 0x8b, 0xea, 0xf5, 
  0x45, 0xdd, 0x71, 0x5d, 0x14, 0x62, 0xc2, 0x80, 
  0x6a, 0xd3, 0x00, 0xbc, 0x86, 0x82, 0xdf, 0x13, 
  0xa6, 0x40, 0x3b, 0x9c, 0xb5, 0x9a, 0xa4, 0x63, 
  0x9e, 0xbf, 0x23, 0xe3, 0xb7, 0xe0, 0x9c, 0x1a, 
  0xa9, 0x78, 0x0d, 0xd9, 0xfa, 0x0d, 0x02, 0xe3, 
  0x04, 0x9c, 0x6a, 0xdd, 0x24, 0xf7, 0xe6, 0xf9, 
  0x33, 0x88, 0x84, 0x38, 0x2c, 0x6c, 0x12, 0x1a, 
  0x04, 0x32, 0x11, 0xc6, 0xef, 0xda, 0x11, 0xaf, 
  0x11, 0x2b, 0x19, 0x83, 0x32, 0x43, 0x47, 0xd0, 
  0x2e, 0x34, 0x49, 0x8f, 0x69, 0xd6, 0xe2, 0x40, 
  0xbc, 0x27, 0x95, 0x40, 0xa3, 0x32, 0x7a, 0x3a, 
  0x27, 0x17, 0x50, 0xe1, 0xb7, 0x65, 0x90, 0x68, 
  0xe2, 0x7d, 0xa4, 0x5c, 0x4f, 0x89, 0x06, 0x11, 
  0xe3, 0xe1, 0x12, 0x1d, 0x7e, 0x30, 0xd0, 0xcd, 
  0xf4, 0xb0, 0xef, 0x67, 0x78, 0x57, 0x3d, 0x8c, 
  0x12, 0x33, 0xa2, 0x9c, 0xb6, 0x80, 0x13, 0xc7, 
  0x28, 0x2a, 0x34, 0xa7, 0x86, 0xe2, 0xf2, 0x4d, 
  0x32, 0x04, 0x9c, 0x79, 0x13, 0x86, 0x2b, 0xe6, 
  0x25, 0x1a, 0xfc, 0x44, 0x84, 0xa0, 0x38, 0x13, 
  0x0b, 0x14, 0xd2, 0xac, 0x23, 0x28, 0xcf, 0x65, 
  0x69, 0x60, 0x58, 0x0f, 0xad, 0x48, 0x9c, 0x88, 
  0x8a, 0x90, 0x83, 0xc2, 0xa1, 0x30, 0xf4, 0x47, 
  0x80, 0x07, 0x9c, 0x05, 0xcf, 0x10, 0x12, 0x47, 
  0xf7, 0x69, 0x1c, 0x03, 0x42, 0x20, 0xa4, 0xb5, 
  0x55, 0x25, 0x03, 0x0a, 0x2f, 0x72, 0xe0, 0xd6, 
  0xc3, 0x6f, 0xd2, 0x8e, 0xbe, 0x82, 0xae, 0xec, 
  0xc1, 0x89, 0x91, 0x7c, 0x48, 0x95, 0x38, 0x1c, 
  0x98, 0xd9, 0x26, 0x37, 0xc7, 0xb3, 0x18, 0x98, 
  0x43, 0xf4, 0x47, 0xa6, 0xcd, 0xa3, 0x91, 0x0a, 
  0xa6, 0x21, 0xd5, 0xe9, 0x10, 0x1a, 0x42, 0xf2, 
  0xa4, 0x2b, 0xb4, 0x97, 0xc6, 0x68, 0x76, 0xe3, 
  0x5a, 0xed, 0x1c, 0x5c, 0xc8, 0xc6, 0x65, 0x2e, 
  0xe0, 0x98, 0x61, 0x8c, 0x1a, 0xdf, 0x7f, 0x49, 
  0x97, 0xb7, 0x2a, 0xcc, 0xca, 0x8b, 0xa4, 0xdb, 
  0x02, 0x35, 0x3f, 0xa5, 0x13, 0x44, 0x54, 0x51, 
  0xa5, 0xe8, 0x70, 0xd1, 0x2c, 0x1a, 0x53, 0x65, 
  0xd0, 0xbc, 0xa6, 0x6c, 0x62, 0xa5, 0x50, 0x74, 
  0xed, 0xad, 0xc6, 0x20, 0x63, 0x0e, 0x07, 0xd8, 
  0xa9, 0xfd, 0xd9, 0xbf, 0xba, 0x86, 0x0e, 0x40, 
  0x9f, 0x8d, 0xb6, 0x18, 0x83, 0x31, 0xba, 0x3e, 
  0x8c, 0xf4, 0xfd, 0xd4, 0xfb, 0x4c, 0x99, 0xf8, 
  0x95, 0x89, 0x50, 0xf6, 0x89, 0x83, 0x56, 0x43, 
  0x9b, 0xa5, 0xbb, 0xb8, 0x89, 0x63, 0x74, 0x52, 
  0x6a, 0x90, 0x9b, 0xf3, 0xa7, 0xbb, 0x44, 0x9e, 
  0x61, 0x06, 0x43, 0x79, 0x51, 0xe4, 0x7d, 0xea, 
  0xa1, 0xa7, 0x58, 0x95, 0xe8, 0x8a, 0xe9, 0x21, 
  0xb4, 0x69, 0xc2, 0x8d, 0xdf, 0x67, 0xa1, 0x89, 
  0x88, 0x77, 0x7d, 0x79, 0xb9, 0x86, 0x70, 0x04, 
  0xac, 0x13, 0x19, 0xe2, 0x7d, 0x3f, 0x2d, 0xbd, 
  0x8c, 0xa2, 0x6e, 0xe5, 0x20, 0x33, 0x58, 0x4b, 
  0x0e, 0x8e, 0x43, 0xec, 0x52, 0x31, 0x44, 0x3b, 
  0x85, 0x98, 0x78, 0x98, 0x07, 0x0d, 0xe2, 0xcd, 
  0xd7, 0x51, 0xf5, 0x49, 0x4a, 0xde, 0xa2, 0x2a, 
  0xf7, 0xaf, 0xec, 0xa6, 0x7a, 0xdc, 0x84, 0x68, 
  0x55, 0xb8, 0x4d, 0x8c, 0x41, 0xd5, 0x53, 0x2d, 
  0x82, 0x44, 0x59, 0xd7, 0xf1, 0x71, 0x1a, 0x93, 
  0xe1, 0x51, 0xe0, 0xb3, 0x1b, 0x37, 0x2c, 0xf6, 
  0x0d, 0x0c, 0xcc, 0x42, 0xd7, 0xba, 0xcb, 0x74, 
  0x72, 0x32, 0x9d, 0x56, 0xac, 0x14, 0x51, 0x8e, 
  0xfc, 0x4d, 0x3c, 0x10, 0xab, 0xa4, 0x98, 0xf6, 
  0x59, 0x37, 0x96, 0xca, 0x50, 0x61, 0x4a, 0xf7, 
  0xb1, 0x3c, 0xd5, 0xbc, 0xfe, 0xfd, 0xf2, 0xdf, 
  0xcb, 0xbf, 0x2f, 0xff, 0xbc, 0xfe, 0xf9, 0xfa, 
  0x97, 0x53, 0xbb, 0xac, 0x5e, 0xad, 0x7a, 0x65, 
  0x20, 0x85, 0x6f, 0x2f, 0x89, 0x37, 0x70, 0x65, 
  0xbb, 0xcd, 0x02, 0x70, 0xd1, 0x47, 0x50, 0x4f, 
  0xaa, 0x96, 0xa6, 0x9f, 0x22, 0xb9, 0x14, 0xd9, 
  0x67, 0xda, 0x38, 0xe5, 0xd9, 0x27, 0xa6, 0xc1, 
  0x33, 0x96, 0x7a, 0x73, 0xea, 0xc0, 0x20, 0xc6, 
  0x25, 0xcb, 0x2d, 0x13, 0xc9, 0xae, 0xec, 0x60, 
  0x5d, 0x28, 0xad, 0x19, 0x67, 0x81, 0xaa, 0x14, 
  0xab, 0x97, 0x15, 0x0d, 0x8f, 0x80, 0x7c, 0x44, 
  0x91, 0x38, 0xad, 0xb3, 0x8d, 0xab, 0x87, 0xd4, 
  0xe1, 0x53, 0xd7, 0xab, 0x1f, 0xc6, 0xcf, 0xce, 
  0x0d, 0x07, 0x5b, 0x3c, 0xcd, 0xc6, 0x9b, 0x2d, 
  0x9d, 0xc6, 0x40, 0x54, 0x4f, 0x5e, 0x3e, 0xb5, 
  0xf5, 0x1c, 0x6b, 0xe4, 0x29, 0x29, 0x2f, 0xd6, 
  0x57, 0x94, 0xf5, 0x56, 0xa2, 0x7a, 0x0e, 0xf5, 
  0xfc, 0xd5, 0x89, 0x61, 0xbc, 0x4d, 0x50, 0x5b, 
  0x74, 0x09, 0xbd, 0x7d, 0x21, 0xba, 0x65, 0x45, 
  0x3e, 0x42, 0xa0, 0x7e, 0x62, 0x04, 0x1e, 0x41, 
  0xf5, 0x90, 0xe4, 0x4e, 0x07, 0x40, 0xed, 0xc4, 
  0x00, 0x7c, 0x4d, 0x8b, 0xdb, 0x3d, 0x6e, 0x7f, 
  0xf9, 0xc0, 0x5e, 0xd9, 0x6d, 0x9e, 0x44, 0x77, 
  0xa2, 0xb7, 0x63, 0x53, 0xdb, 0x9e, 0x72, 0xfb, 
  0x03, 0xd8, 0x35, 0x76, 0xf0, 0xde, 0x35, 0xf2, 
  0x7f, 0x88, 0x3b, 0xb2, 0x27, 0xab, 0xdd, 0xf8, 
  0xb6, 0x76, 0x0e, 0x7c, 0xfb, 0xfe, 0xe4, 0x69, 
  0xcb, 0x9a, 0xcb, 0xa9, 0xbe, 0xbd, 0x70, 0xdb, 
  0xbe, 0x98, 0x58, 0x1e, 0x69, 0x27, 0xa7, 0x3e, 
  0x05, 0x6d, 0xc0, 0x3a, 0x75, 0x35, 0xfd, 0x4f, 
  0x84, 0x44, 0x3c, 0x9e, 0xe0, 0xea, 0xa1, 0x46, 
  0x87, 0x3a, 0x87, 0x2a, 0x6e, 0x6f, 0xef, 0x6d, 
  0x33, 0xce, 0x4b, 0x91, 0x8f, 0xa5, 0x66, 0xd9, 
  0x01, 0xf2, 0x72, 0x3b, 0x7f, 0xf8, 0x4a, 0x85, 
  0x3d, 0x0a, 0xa4, 0x8d, 0x15, 0x7b, 0xb9, 0x1f, 
  0xbe, 0x2d, 0x91, 0xec, 0x8d, 0x30, 0x28, 0x91, 
  0x2b, 0x3d, 0x21, 0x2f, 0x45, 0xa3, 0xbe, 0xde, 
  0xa1, 0x7f, 0x76, 0xf7, 0xb5, 0x63, 0xec, 0x7e, 
  0xac, 0xe5, 0xd5, 0x7a, 0x5a, 0x3e, 0x06, 0x4a, 
  0x72, 0x0e, 0xe1, 0xa8, 0x4d, 0x63, 0xd5, 0xd5, 
  0xf9, 0x58, 0x3f, 0x1d, 0x3b, 0x8a, 0xde, 0x3a, 
  0xa2, 0xf8, 0x2a, 0xdf, 0xa6, 0x19, 0xe2, 0x31, 
  0xb1, 0x56, 0x9b, 0x40, 0x01, 0xfc, 0xc2, 0xa0, 
  0x3f, 0xdd, 0xa4, 0xe4, 0x4c, 0x9b, 0x63, 0x28, 
  0xdc, 0x95, 0x21, 0x72, 0x8d, 0x37, 0xd5, 0x1b, 
  0x5d, 0x7a, 0x6c, 0xce, 0x48, 0xd0, 0x55, 0xc0, 
  0x81, 0x6a, 0x70, 0xa1, 0x87, 0x9e, 0x37, 0xd9, 
  0x0e, 0xcf, 0x17, 0xc9, 0xc4, 0xfc, 0x5c, 0x6c, 
  0xfe, 0x10, 0x9d, 0xa5, 0xe2, 0xf4, 0xa3, 0x07, 
  0xae, 0xed, 0xa6, 0xb7, 0x08, 0x1d, 0x8a, 0x07, 
  0x99, 0xcd, 0x17, 0x83, 0xf4, 0x58, 0x08, 0x64, 
  0xac, 0x8c, 0x43, 0x3d, 0xc4, 0xcd, 0x2d, 0x26, 
  0x5a, 0x0b, 0x4f, 0x1f, 0xf3, 0x51, 0xb5, 0xce, 
  0xd4, 0x31, 0xbf, 0xd8, 0xe7, 0x68, 0x8e, 0x5f, 
  0xc8, 0x6c, 0xdb, 0xb7, 0x1f, 0xd9, 0xef, 0x2e, 
  0x6d, 0x24, 0x4e, 0xeb, 0x96, 0x35, 0x17, 0x17, 
  0xf0, 0xc5, 0xf2, 0x66, 0xdf, 0xb7, 0xeb, 0xf8, 
  0xcc, 0x1d, 0x70, 0xfe, 0x00, 0x36, 0xe7, 0x82, 
  0x7a, 0x4a, 0x7b, 0x3b, 0xb3, 0xbe, 0xe3, 0x67, 
  0x4d, 0xe9, 0xf9, 0x37, 0x43, 0xc8, 0xd2, 0xd7, 
  0x95, 0x34, 0xe8, 0xad, 0xd8, 0x42, 0xe4, 0x14, 
  0xba, 0xf7, 0xe8, 0xe1, 0x32, 0xc8, 0xa8, 0x31, 
  0x8a, 0xa1, 0x17, 0x80, 0x9e, 0xb8, 0x1e, 0xed, 
  0xdc, 0xaa, 0xeb, 0x61, 0x3d, 0x51, 0x3c, 0xf0, 
  0x26, 0xae, 0xf5, 0x8a, 0x32, 0x61, 0x7b, 0x03, 
  0x5c, 0x6d, 0x62, 0x80, 0x9b, 0xd8, 0x5c, 0xec, 
  0xc9, 0x06, 0x45, 0x8b, 0xff, 0x5c, 0xcd, 0x50, 
  0xdb, 0xc2, 0x0c, 0x9b, 0x97, 0x6f, 0x0a, 0x34, 
  0xfb, 0x03, 0xca, 0xb3, 0xb9, 0x8e, 0x14, 0x13, 
  0xcf, 0x3b, 0xb5, 0xc3, 0x4a, 0xb3, 0x40, 0xfd, 
  0x4d, 0x64, 0x81, 0xfc, 0xfb, 0xcd, 0x91, 0x93, 
  0xc0, 0xe4, 0x57, 0xa3, 0xf9, 0xa3, 0xd3, 0xfe, 
  0xf9, 0xba, 0x9e, 0x7d, 0x80, 0xd9, 0x35, 0xba, 
  0x6b, 0x9b, 0x44, 0xf7, 0x4f, 0xf8, 0x7c, 0xfb, 
  0xe8, 0x9e, 0xb0, 0x4b, 0x56, 0x60, 0x57, 0xce, 
  0x8f, 0xec, 0xde, 0x6f, 0x02, 0xc7, 0x2d, 0x53, 
  0x26, 0x0a, 0xe9, 0x70, 0x3f, 0x90, 0xb4, 0xf2, 
  0xd5, 0x26, 0xed, 0xba, 0x47, 0xfe, 0x28, 0x8d, 
  0xba, 0x75, 0xe9, 0xe3, 0x4d, 0x31, 0x56, 0xf5, 
  0x4d, 0x30, 0x56, 0xfa, 0x09, 0xf7, 0x88, 0x5c, 
  0x35, 0xf1, 0xc9, 0xf8, 0x18, 0x54, 0x55, 0xdd, 
  0x0f, 0x55, 0xd5, 0x37, 0x89, 0xcd, 0xbc, 0xd1, 
  0xbb, 0x7d, 0x68, 0x06, 0x38, 0xaa, 0xf2, 0x51, 
  0xcb, 0x44, 0xf5, 0xc3, 0xd1, 0xd5, 0x5b, 0x08, 
  0xea, 0x03, 0x35, 0x15, 0xaa, 0x6b, 0xaa, 0x55, 
  0x0c, 0x8c, 0xfe, 0x5f, 0x80, 0x97, 0xe3, 0x3f, 
  0x7e, 0xbd, 0xfb, 0x1f, 0x2b, 0xd7, 0xfd, 0xfc, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x28, 0x75, 0x75, 0x61, 0x79, 0x29
} };

static GStaticResource static_resource = { kvartplata_resource_data.data, sizeof (kvartplata_resource_data.data), NULL, NULL, NULL };
extern GResource *kvartplata_get_resource (void);
GResource *kvartplata_get_resource (void)
{
  return g_static_resource_get_resource (&static_resource);
}
/*
  If G_HAS_CONSTRUCTORS is true then the compiler support *both* constructors and
  destructors, in a sane way, including e.g. on library unload. If not you're on
  your own.

  Some compilers need #pragma to handle this, which does not work with macros,
  so the way you need to use this is (for constructors):

  #ifdef G_DEFINE_CONSTRUCTOR_NEEDS_PRAGMA
  #pragma G_DEFINE_CONSTRUCTOR_PRAGMA_ARGS(my_constructor)
  #endif
  G_DEFINE_CONSTRUCTOR(my_constructor)
  static void my_constructor(void) {
   ...
  }

*/

#if  __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7)

#define G_HAS_CONSTRUCTORS 1

#define G_DEFINE_CONSTRUCTOR(_func) static void __attribute__((constructor)) _func (void);
#define G_DEFINE_DESTRUCTOR(_func) static void __attribute__((destructor)) _func (void);

#elif defined (_MSC_VER) && (_MSC_VER >= 1500)
/* Visual studio 2008 and later has _Pragma */

#define G_HAS_CONSTRUCTORS 1

#define G_DEFINE_CONSTRUCTOR(_func) \
  static void _func(void); \
  static int _func ## _wrapper(void) { _func(); return 0; } \
  __pragma(section(".CRT$XCU",read)) \
  __declspec(allocate(".CRT$XCU")) static int (* _array ## _func)(void) = _func ## _wrapper;

#define G_DEFINE_DESTRUCTOR(_func) \
  static void _func(void); \
  static int _func ## _constructor(void) { atexit (_func); return 0; } \
  __pragma(section(".CRT$XCU",read)) \
  __declspec(allocate(".CRT$XCU")) static int (* _array ## _func)(void) = _func ## _constructor;

#elif defined (_MSC_VER)

#define G_HAS_CONSTRUCTORS 1

/* Pre Visual studio 2008 must use #pragma section */
#define G_DEFINE_CONSTRUCTOR_NEEDS_PRAGMA 1
#define G_DEFINE_DESTRUCTOR_NEEDS_PRAGMA 1

#define G_DEFINE_CONSTRUCTOR_PRAGMA_ARGS(_func) \
  section(".CRT$XCU",read)
#define G_DEFINE_CONSTRUCTOR(_func) \
  static void _func(void); \
  static int _func ## _wrapper(void) { _func(); return 0; } \
  __declspec(allocate(".CRT$XCU")) static int (*p)(void) = _func ## _wrapper;

#define G_DEFINE_DESTRUCTOR_PRAGMA_ARGS(_func) \
  section(".CRT$XCU",read)
#define G_DEFINE_DESTRUCTOR(_func) \
  static void _func(void); \
  static int _func ## _constructor(void) { atexit (_func); return 0; } \
  __declspec(allocate(".CRT$XCU")) static int (* _array ## _func)(void) = _func ## _constructor;

#elif defined(__SUNPRO_C)

/* This is not tested, but i believe it should work, based on:
 * http://opensource.apple.com/source/OpenSSL098/OpenSSL098-35/src/fips/fips_premain.c
 */

#define G_HAS_CONSTRUCTORS 1

#define G_DEFINE_CONSTRUCTOR_NEEDS_PRAGMA 1
#define G_DEFINE_DESTRUCTOR_NEEDS_PRAGMA 1

#define G_DEFINE_CONSTRUCTOR_PRAGMA_ARGS(_func) \
  init(_func)
#define G_DEFINE_CONSTRUCTOR(_func) \
  static void _func(void);

#define G_DEFINE_DESTRUCTOR_PRAGMA_ARGS(_func) \
  fini(_func)
#define G_DEFINE_DESTRUCTOR(_func) \
  static void _func(void);

#else

/* constructors not supported for this compiler */

#endif


#ifdef G_HAS_CONSTRUCTORS

#ifdef G_DEFINE_CONSTRUCTOR_NEEDS_PRAGMA
#pragma G_DEFINE_CONSTRUCTOR_PRAGMA_ARGS(resource_constructor)
#endif
G_DEFINE_CONSTRUCTOR(resource_constructor)
#ifdef G_DEFINE_DESTRUCTOR_NEEDS_PRAGMA
#pragma G_DEFINE_DESTRUCTOR_PRAGMA_ARGS(resource_destructor)
#endif
G_DEFINE_DESTRUCTOR(resource_destructor)

#else
#warning "Constructor not supported on this compiler, linking in resources will not work"
#endif

static void resource_constructor (void)
{
  g_static_resource_init (&static_resource);
}

static void resource_destructor (void)
{
  g_static_resource_fini (&static_resource);
}
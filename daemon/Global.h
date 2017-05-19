extern mach_port_t SBSSpringBoardServerPort();
extern void SBFrontmostApplicationDisplayIdentifier(mach_port_t port, char *identifier);
extern void SBGetScreenLockStatus(mach_port_t port, bool *isLocked, bool *passcodeLocked);

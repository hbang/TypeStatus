extern BOOL CKIsRunningInFullCKClient();

%hookf(BOOL, CKIsRunningInFullCKClient) {
	return YES;
}

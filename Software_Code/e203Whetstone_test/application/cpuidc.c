#include <stdio.h>
#include "cpuidh.h"
#include "config.h"
#include "hbird_sdk_soc.h"

volatile SPDP  theseSecs = 0.0;
volatile SPDP  startSecs = 0.0;
volatile SPDP  secs;

SPDP time()
{
    return (SPDP) SysTimer_GetLoadValue() / SOC_TIMER_FREQ;
}

void getSecs()
{
	theseSecs = time() ;
	return;
}

void start_time()
{
	getSecs();
	startSecs = theseSecs;
	return;
}

void end_time()
{
	getSecs();
//	printf("theseSecs = %f \n", theseSecs);
//	printf("startSecs = %f \n", startSecs);
	secs = theseSecs - startSecs;
	return;
}

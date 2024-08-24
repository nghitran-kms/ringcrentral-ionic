interface RCMeetingRequest {
  meetingId: string;
  userName: string;
  apptEndTime: Date;
}

interface RCMeetingResponse {
  isManualLeave: boolean;
}

interface RCConfig {
  clientId: string;
  clientSecret: string;
}

export interface RingCentralPlugin {
  /**
   * Join Meeting
   */
  joinMeeting(request: RCMeetingRequest): Promise<RCMeetingResponse>;

  /**
   * Init RingCentral in native
   */
  initRingCentral(config: RCConfig): Promise<void>;
}

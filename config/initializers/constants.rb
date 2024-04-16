FAKE_POPULI_URL = "https://fake-populi-domain.com"
FAKE_POPULI_ACCESS_KEY = "abc123"
# set the populi url/key to a fake credentials if not set in the environment
ENV["POPULI_API_URL"] ||= FAKE_POPULI_URL 
ENV["POPULI_API_ACCESS_KEY"] ||= FAKE_POPULI_ACCESS_KEY
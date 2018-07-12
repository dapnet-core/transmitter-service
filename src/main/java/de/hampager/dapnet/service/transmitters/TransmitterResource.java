package de.hampager.dapnet.service.transmitters;

import javax.inject.Inject;
import javax.inject.Singleton;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.UriInfo;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Singleton
@Path("transmitters")
public final class TransmitterResource {

	@Inject
	private ObjectMapper objectMapper;
	@Context
	private UriInfo uriInfo;
	@Context
	private HttpHeaders httpHeaders;

	@POST
	@Path("bootstrap")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public String bootstrap(String request) throws Exception {
		JsonNode json = objectMapper.readTree(request);
		return "{}";
	}

	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public String getTransmitters() {
		return "{}";
	}

	public String getTransmitter(String id) {
		return "{}";
	}

}
